package com.mapple.util;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Component;

import java.io.IOException;
import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

@Component
public class NexonApiUtil {

    @Value("${nexon.api.key}")
    private String apiKey;

    @Value("${nexon.api.base-url}")
    private String baseUrl;

    private final HttpClient httpClient = HttpClient.newHttpClient();
    private final ObjectMapper objectMapper = new ObjectMapper();

    // 공통 GET 요청 — 429(rate limit)만 최대 3회 재시도, 400 등 다른 오류는 즉시 반환
    private JsonNode get(String path) {
        int maxRetry = 3;
        for (int attempt = 0; attempt < maxRetry; attempt++) {
            try {
                if (attempt > 0) {
                    Thread.sleep(1200L * attempt); // 1.2s, 2.4s 대기
                }
                HttpRequest request = HttpRequest.newBuilder()
                        .uri(URI.create(baseUrl + path))
                        .header("x-nxopen-api-key", apiKey)
                        .GET()
                        .build();
                HttpResponse<String> response =
                        httpClient.send(request, HttpResponse.BodyHandlers.ofString());
                if (response.statusCode() == 200) {
                    return objectMapper.readTree(response.body());
                }
                System.err.println("[NexonAPI] 오류 " + response.statusCode()
                        + " | path=" + path
                        + " | body=" + response.body());
                // 429(rate limit)만 재시도 — 400/404 등 파라미터 오류는 즉시 중단
                if (response.statusCode() != 429 || attempt >= maxRetry - 1) {
                    return null;
                }
                System.err.println("[NexonAPI] 429 rate limit, " + (attempt + 1) + "초 후 재시도...");
            } catch (IOException | InterruptedException e) {
                e.printStackTrace();
                return null;
            }
        }
        return null;
    }

    // 캐릭터 OCID 조회 — 한글 닉네임 URL 인코딩 필수
    public String getOcid(String characterName) {
        try {
            String encoded = URLEncoder.encode(characterName, StandardCharsets.UTF_8);
            JsonNode node = get("/maplestory/v1/id?character_name=" + encoded);
            if (node != null && node.has("ocid")) {
                return node.get("ocid").asText();
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return null;
    }

    // 캐릭터 기본 정보
    public JsonNode getBasicInfo(String ocid) {
        return get("/maplestory/v1/character/basic?ocid=" + ocid);
    }

    // 캐릭터 코디 아이템
    public JsonNode getCashItemEquipment(String ocid) {
        return get("/maplestory/v1/character/cashitem-equipment?ocid=" + ocid);
    }

    // 캐릭터 스탯
    public JsonNode getStat(String ocid) {
        return get("/maplestory/v1/character/stat?ocid=" + ocid);
    }

    // 일반 공지사항 목록
    public JsonNode getNotices() {
        return get("/maplestory/v1/notice");
    }

    // 업데이트(패치노트) 공지 목록
    public JsonNode getUpdateNotices() {
        return get("/maplestory/v1/notice-update");
    }

    // 업데이트 공지 상세
    public JsonNode getUpdateNoticeDetail(String noticeId) {
        return get("/maplestory/v1/notice-update/detail?notice_id=" + noticeId);
    }

    // 일반 공지 상세
    public JsonNode getNoticeDetail(String noticeId) {
        return get("/maplestory/v1/notice/detail?notice_id=" + noticeId);
    }

    // 진행 중인 이벤트 공지 목록
    public JsonNode getEventNotices() {
        return get("/maplestory/v1/notice-event");
    }

    // 캐시샵 판매 공지 목록
    public JsonNode getCashShopNotices() {
        return get("/maplestory/v1/notice-cashshop");
    }

    // 이벤트 공지 상세
    public JsonNode getEventNoticeDetail(String noticeId) {
        return get("/maplestory/v1/notice-event/detail?notice_id=" + noticeId);
    }

    // 캐시샵 공지 상세
    public JsonNode getCashShopNoticeDetail(String noticeId) {
        return get("/maplestory/v1/notice-cashshop/detail?notice_id=" + noticeId);
    }

    // 캐릭터 장비 아이템
    public JsonNode getItemEquipment(String ocid) {
        return get("/maplestory/v1/character/item-equipment?ocid=" + ocid);
    }

    // 유니온 정보 (date 없이 — 최신 데이터 자동 반환)
    public JsonNode getUnion(String ocid) {
        return get("/maplestory/v1/user/union?ocid=" + ocid);
    }

    // 인기도 (date 없이)
    public JsonNode getPopularity(String ocid) {
        return get("/maplestory/v1/character/popularity?ocid=" + ocid);
    }

    // 유니온 레이더 (date 없이)
    public JsonNode getUnionRaider(String ocid) {
        return get("/maplestory/v1/user/union-raider?ocid=" + ocid);
    }

    // ── 랭킹 APIs ────────────────────────────────────────────

    // 종합 랭킹
    public JsonNode getOverallRanking(String worldName, String className, int page) {
        StringBuilder path = new StringBuilder(
                "/maplestory/v1/ranking/overall?date=" + yesterday() + "&page=" + page);
        if (worldName != null && !worldName.isBlank())
            path.append("&world_name=").append(enc(worldName));
        return get(path.toString());
    }

    // 유니온 랭킹
    public JsonNode getUnionRanking(String worldName, int page) {
        StringBuilder path = new StringBuilder(
                "/maplestory/v1/ranking/union?date=" + yesterday() + "&page=" + page);
        if (worldName != null && !worldName.isBlank())
            path.append("&world_name=").append(enc(worldName));
        return get(path.toString());
    }

    // 무릉도장 랭킹 (difficulty: 0=일반, 1=통달)
    public JsonNode getDojangRanking(String worldName, String className, int page) {
        StringBuilder path = new StringBuilder(
                "/maplestory/v1/ranking/dojang?date=" + yesterday() + "&difficulty=1&page=" + page);
        if (worldName != null && !worldName.isBlank())
            path.append("&world_name=").append(enc(worldName));
        return get(path.toString());
    }

    // 더 시드 랭킹
    public JsonNode getTheSeedRanking(String worldName, int page) {
        StringBuilder path = new StringBuilder(
                "/maplestory/v1/ranking/the-seed?date=" + yesterday() + "&page=" + page);
        if (worldName != null && !worldName.isBlank())
            path.append("&world_name=").append(enc(worldName));
        return get(path.toString());
    }

    // 업적 랭킹
    public JsonNode getAchievementRanking(int page) {
        return get("/maplestory/v1/ranking/achievement?date=" + yesterday() + "&page=" + page);
    }

    // ── 스킬 / 아티팩트 APIs ──────────────────────────────────

    // 6차 헥사 코어
    public JsonNode getHexaMatrix(String ocid) {
        return get("/maplestory/v1/character/hexamatrix?ocid=" + ocid);
    }

    // 헥사 스탯
    public JsonNode getHexaMatrixStat(String ocid) {
        return get("/maplestory/v1/character/hexamatrix-stat?ocid=" + ocid);
    }

    // 5차 V매트릭스
    public JsonNode getVMatrix(String ocid) {
        return get("/maplestory/v1/character/vmatrix?ocid=" + ocid);
    }

    // 유니온 아티팩트
    public JsonNode getUnionArtifact(String ocid) {
        return get("/maplestory/v1/user/union-artifact?ocid=" + ocid);
    }

    // ── 내부 헬퍼 ────────────────────────────────────────────
    private String yesterday() {
        return java.time.LocalDate.now().minusDays(1)
                .format(java.time.format.DateTimeFormatter.ofPattern("yyyy-MM-dd"));
    }

    private String enc(String s) {
        return URLEncoder.encode(s, StandardCharsets.UTF_8);
    }
}
