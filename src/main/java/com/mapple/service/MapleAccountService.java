package com.mapple.service;

import com.fasterxml.jackson.databind.JsonNode;
import com.mapple.dto.MapleCharacterDto;
import com.mapple.dto.SyncResultDto;
import com.mapple.entity.MapleAccount;
import com.mapple.entity.MapleCharacter;
import com.mapple.exception.CharacterNotFoundException;
import com.mapple.exception.CooldownException;
import com.mapple.repository.MapleAccountRepository;
import com.mapple.repository.MapleCharacterRepository;
import com.mapple.util.NexonApiUtil;
import jakarta.transaction.Transactional;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import java.time.Duration;
import java.time.LocalDateTime;
import java.util.*;
import java.util.concurrent.*;
import java.util.stream.Collectors;

@Service
@Transactional
public class MapleAccountService {

    private static final int COOLDOWN_MINUTES = 10;

    /**
     * 넥슨 API 병렬 호출용 스레드 풀
     * — 3개로 제한해 초당 5건 Rate Limit 를 최대한 준수
     */
    private final ExecutorService nexonExecutor = Executors.newFixedThreadPool(3);

    @Autowired private MapleAccountRepository accountRepo;
    @Autowired private MapleCharacterRepository characterRepo;
    @Autowired private NexonApiUtil nexonApiUtil;

    // ─────────────────────────────────────────────────────────────
    // 1. 기본 조회 — DB 우선, 없으면 Nexon API 최초 1회 호출
    // ─────────────────────────────────────────────────────────────
    public List<MapleCharacterDto> getAlts(String charName) {
        Optional<MapleCharacter> cached = characterRepo.findByCharName(charName);

        if (cached.isPresent()) {
            MapleCharacter mc = cached.get();

            // is_valid=false : 이미 존재하지 않는 것으로 확인된 캐릭터
            if (!mc.isValid()) {
                throw new CharacterNotFoundException("존재하지 않는 캐릭터입니다: " + charName);
            }

            // DB 에 데이터 있음 → API 호출 없이 즉시 반환
            return toDto(characterRepo.findByMapleAccountOrderByCharLevelDesc(mc.getMapleAccount()));
        }

        // DB 에 없음 → Nexon API 연쇄 호출 후 저장
        return fetchAndSave(charName);
    }

    // ─────────────────────────────────────────────────────────────
    // 2. 수동 갱신 — 10분 쿨타임 체크 후 Nexon API 재호출
    // ─────────────────────────────────────────────────────────────
    public SyncResultDto sync(String charName) {

        // DB 에서 계정 찾기 (이름이 부캐일 수 있으므로 캐릭터 → 계정 경로)
        Optional<MapleCharacter> cached = characterRepo.findByCharName(charName);

        if (cached.isPresent() && !cached.get().isValid()) {
            throw new CharacterNotFoundException("존재하지 않는 캐릭터입니다: " + charName);
        }

        MapleAccount account = cached.map(MapleCharacter::getMapleAccount).orElse(null);

        if (account != null && account.getLastUpdatedAt() != null) {
            long elapsedMinutes = Duration.between(account.getLastUpdatedAt(), LocalDateTime.now()).toMinutes();
            if (elapsedMinutes < COOLDOWN_MINUTES) {
                long remaining = COOLDOWN_MINUTES - elapsedMinutes;
                throw new CooldownException("아직 갱신 쿨타임 중입니다. (남은 시간: " + remaining + "분)");
            }
        }

        // 쿨타임 통과 → 최신 정보로 갱신
        List<MapleCharacterDto> result = fetchAndSave(charName);
        return new SyncResultDto("갱신 완료", LocalDateTime.now(), result);
    }

    // ─────────────────────────────────────────────────────────────
    // 3. Nexon API 연쇄 호출 → DB 저장
    // ─────────────────────────────────────────────────────────────
    private List<MapleCharacterDto> fetchAndSave(String charName) {

        // ① 대표 캐릭터 ocid 조회
        String mainOcid = nexonApiUtil.getOcid(charName);
        if (mainOcid == null) {
            cacheInvalid(charName);
            throw new CharacterNotFoundException("존재하지 않는 캐릭터입니다: " + charName);
        }

        // ② 유니온 레벨 + 부캐 이름 목록 확보
        JsonNode unionInfo   = nexonApiUtil.getUnion(mainOcid);
        JsonNode unionRaider = nexonApiUtil.getUnionRaider(mainOcid);

        int unionLevel = (unionInfo != null)
                ? unionInfo.path("union_level").asInt(0) : 0;

        List<String> allNames = extractSubCharNames(unionRaider, charName);

        // ③ 모든 캐릭터 상세 정보를 병렬로 호출 (basic + stat 동시)
        List<CharDetail> details = fetchAllDetailsInParallel(allNames);

        // ④ 레벨 내림차순 정렬 (0번 = 본캐)
        details.sort(Comparator.comparingInt(CharDetail::level).reversed());

        // ⑤ DB 저장 (upsert)
        return persistToDb(charName, mainOcid, unionLevel, details);
    }

    // ─────────────────────────────────────────────────────────────
    // 병렬 상세 조회 — 각 캐릭터마다 basic + stat 동시 요청
    // ─────────────────────────────────────────────────────────────
    private List<CharDetail> fetchAllDetailsInParallel(List<String> names) {
        // 각 캐릭터를 nexonExecutor 로 병렬 처리
        List<CompletableFuture<CharDetail>> futures = names.stream()
                .map(name -> CompletableFuture.supplyAsync(
                        () -> fetchSingleDetail(name), nexonExecutor))
                .collect(Collectors.toList());

        // 전체 완료 대기 (최대 5분)
        try {
            CompletableFuture.allOf(futures.toArray(new CompletableFuture[0]))
                    .get(5, TimeUnit.MINUTES);
        } catch (TimeoutException e) {
            System.err.println("[MapleAccountService] 병렬 조회 타임아웃");
        } catch (Exception e) {
            System.err.println("[MapleAccountService] 병렬 조회 오류: " + e.getMessage());
        }

        return futures.stream()
                .map(f -> {
                    try { return f.isDone() ? f.get() : null; }
                    catch (Exception e) { return null; }
                })
                .filter(Objects::nonNull)
                .collect(Collectors.toList());
    }

    /**
     * 단일 캐릭터: ocid 확보 → basic 과 stat 을 CompletableFuture 로 동시 요청
     */
    private CharDetail fetchSingleDetail(String name) {
        try {
            String ocid = nexonApiUtil.getOcid(name);
            if (ocid == null) return null;

            // basic + stat 두 API 를 같은 nexonExecutor 안에서 병렬 실행
            CompletableFuture<JsonNode> basicFuture =
                    CompletableFuture.supplyAsync(() -> nexonApiUtil.getBasicInfo(ocid), nexonExecutor);
            CompletableFuture<JsonNode> statFuture =
                    CompletableFuture.supplyAsync(() -> nexonApiUtil.getStat(ocid), nexonExecutor);

            JsonNode basic = basicFuture.join();
            JsonNode stat  = statFuture.join();

            if (basic == null) return null;

            int    level      = basic.path("character_level").asInt(0);
            String charClass  = basic.path("character_class").asText("");
            String guildName  = basic.path("character_guild_name").asText("");
            String imageUrl   = basic.path("character_image").asText("");
            long   combatPower = parseCombatPower(stat);

            return new CharDetail(name, ocid, level, charClass, guildName, imageUrl, combatPower);

        } catch (Exception e) {
            System.err.println("[MapleAccountService] 상세 조회 실패: " + name + " — " + e.getMessage());
            return null;
        }
    }

    // ─────────────────────────────────────────────────────────────
    // DB 저장 (Upsert)
    // ─────────────────────────────────────────────────────────────
    private List<MapleCharacterDto> persistToDb(
            String repCharName, String mainOcid, int unionLevel, List<CharDetail> details) {

        // MapleAccount — 기존 행 재사용 또는 신규 생성
        MapleAccount account = accountRepo.findByOcid(mainOcid)
                .orElseGet(MapleAccount::new);

        account.setOcid(mainOcid);
        account.setRepCharName(repCharName);
        account.setUnionLevel(unionLevel);
        account.setLastUpdatedAt(LocalDateTime.now());
        account.getCharacters().clear();          // orphanRemoval 로 기존 캐릭터 행 삭제
        account = accountRepo.saveAndFlush(account);

        // MapleCharacter 순서대로 저장
        List<MapleCharacterDto> result = new ArrayList<>();
        boolean isMain = true;

        for (CharDetail d : details) {
            MapleCharacter mc = new MapleCharacter();
            mc.setMapleAccount(account);
            mc.setCharName(d.name());
            mc.setCharOcid(d.ocid());
            mc.setCharLevel(d.level());
            mc.setCharClass(d.charClass());
            mc.setGuildName(d.guildName());
            mc.setImageUrl(d.imageUrl());
            mc.setCombatPower(d.combatPower());
            mc.setValid(true);
            characterRepo.save(mc);

            result.add(MapleCharacterDto.from(mc, isMain));
            isMain = false;
        }

        return result;
    }

    // ─────────────────────────────────────────────────────────────
    // 존재하지 않는 캐릭터 캐싱 (is_valid = false)
    // ─────────────────────────────────────────────────────────────
    private void cacheInvalid(String charName) {
        if (characterRepo.findByCharName(charName).isPresent()) return;

        MapleAccount ghost = new MapleAccount();
        ghost.setOcid("INVALID-" + charName);
        ghost.setRepCharName(charName);
        ghost.setUnionLevel(0);
        ghost.setLastUpdatedAt(LocalDateTime.now());
        ghost = accountRepo.save(ghost);

        MapleCharacter mc = new MapleCharacter();
        mc.setMapleAccount(ghost);
        mc.setCharName(charName);
        mc.setValid(false);
        characterRepo.save(mc);
    }

    // ─────────────────────────────────────────────────────────────
    // 유니온 레이더에서 부캐 이름 목록 추출
    // ─────────────────────────────────────────────────────────────
    /**
     * 넥슨 API /maplestory/v1/user/union-raider 응답의 union_block 배열을 파싱합니다.
     *
     * ※ 실제 API 응답에서 union_block 항목이 character_name 필드를 포함하지 않을 수 있습니다.
     *    실제 응답 JSON 을 확인한 후 필드명을 조정하세요.
     *    현재는 "character_name" 필드가 있다고 가정하고 구현되어 있습니다.
     */
    private List<String> extractSubCharNames(JsonNode unionRaider, String mainCharName) {
        List<String> names = new ArrayList<>();
        names.add(mainCharName); // 본캐 항상 첫 번째

        if (unionRaider == null) return names;

        JsonNode blocks = unionRaider.path("union_block");
        if (blocks.isArray()) {
            for (JsonNode block : blocks) {
                // ↓ 실제 Nexon API 응답 필드명 확인 후 수정 필요
                String name = block.path("character_name").asText("").trim();
                if (!name.isBlank() && !names.contains(name)) {
                    names.add(name);
                }
            }
        }

        return names;
    }

    // ─────────────────────────────────────────────────────────────
    // 헬퍼
    // ─────────────────────────────────────────────────────────────
    private long parseCombatPower(JsonNode stat) {
        if (stat == null) return 0L;
        for (JsonNode s : stat.path("final_stat")) {
            if ("전투력".equals(s.path("stat_name").asText())) {
                String raw = s.path("stat_value").asText("0").replaceAll("[^0-9]", "");
                try { return Long.parseLong(raw); } catch (NumberFormatException ignored) {}
            }
        }
        return 0L;
    }

    private List<MapleCharacterDto> toDto(List<MapleCharacter> list) {
        List<MapleCharacterDto> result = new ArrayList<>();
        boolean isMain = true;
        for (MapleCharacter mc : list) {
            if (mc.isValid()) {
                result.add(MapleCharacterDto.from(mc, isMain));
                isMain = false;
            }
        }
        return result;
    }

    /** 캐릭터 1명의 Nexon API 조회 결과 임시 보관용 레코드 */
    private record CharDetail(String name, String ocid, int level,
                              String charClass, String guildName,
                              String imageUrl, long combatPower) {}
}
