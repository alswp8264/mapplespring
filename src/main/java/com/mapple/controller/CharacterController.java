package com.mapple.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapple.dto.FavoriteDto;
import com.mapple.dto.MemberDto;
import com.mapple.dto.SpecHistoryDto;
import com.mapple.service.FavoriteService;
import com.mapple.util.NexonApiUtil;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Controller
@RequestMapping("/character")
public class CharacterController {

    @Autowired
    private NexonApiUtil nexonApiUtil;

    @Autowired
    private FavoriteService favoriteService;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @SuppressWarnings("unchecked")
    private Map<String, Object> toMap(JsonNode node) {
        if (node == null || node.isNull()) return new HashMap<>();
        return objectMapper.convertValue(node, Map.class);
    }

    // ─────────────────────────────────────────────────────────
    // 캐릭터 검색
    @GetMapping("/search")
    public String search(@RequestParam(name = "charName", required = false) String charName,
                         Model model, HttpSession session) {

        if (charName == null || charName.trim().isEmpty()) {
            return "character/result";
        }

        charName = charName.trim();
        model.addAttribute("charName", charName);

        // ── 즐겨찾기 상태 ────────────────────────────────────
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember != null) {
            final String cn = charName;
            favoriteService.getList(loginMember.getMemberId()).stream()
                .filter(f -> f.getCharName().equals(cn))
                .findFirst()
                .ifPresent(f -> {
                    model.addAttribute("isFavorite", true);
                    model.addAttribute("favId", f.getFavId());
                });
        }

        String ocid = nexonApiUtil.getOcid(charName);
        if (ocid == null) {
            model.addAttribute("errorMsg", "'" + charName + "' 캐릭터를 찾을 수 없습니다. 닉네임을 확인하거나, 최근 30일 내 접속한 캐릭터만 조회 가능합니다.");
            return "character/result";
        }

        model.addAttribute("ocid", ocid);

        // ── 기본 정보 ──────────────────────────────────────────
        try {
            JsonNode basicNode = nexonApiUtil.getBasicInfo(ocid);
            if (basicNode != null) {
                model.addAttribute("basic", toMap(basicNode));
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 스탯 ──────────────────────────────────────────────
        try {
            JsonNode statNode = nexonApiUtil.getStat(ocid);
            if (statNode != null && statNode.has("final_stat")) {
                List<Map<String, Object>> statList = new ArrayList<>();
                Map<String, String> statMap = new HashMap<>();
                for (JsonNode s : statNode.get("final_stat")) {
                    statList.add(toMap(s));
                    statMap.put(s.path("stat_name").asText(), s.path("stat_value").asText());
                }
                model.addAttribute("statList", statList);
                model.addAttribute("statMap", statMap);
                // 전투력 → "1억 3,345만" 형태로 변환
                String cp = statMap.get("전투력");
                if (cp != null && !cp.isBlank()) {
                    model.addAttribute("combatPowerText", formatCombatPower(cp));
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 장비 아이템 ────────────────────────────────────────
        try {
            JsonNode equipNode = nexonApiUtil.getItemEquipment(ocid);
            if (equipNode != null && equipNode.has("item_equipment")) {
                List<Map<String, Object>> equipList = new ArrayList<>();
                for (JsonNode item : equipNode.get("item_equipment")) {
                    Map<String, Object> m = toMap(item);
                    m.put("gradeClass",    toGradeClass(safeStr(m, "potential_option_grade")));
                    m.put("addGradeClass", toGradeClass(safeStr(m, "additional_potential_option_grade")));
                    equipList.add(m);
                }
                model.addAttribute("equipList", equipList);

                // 슬롯명 → 장비 맵 (메아기 스타일 슬롯 레이아웃용)
                Map<String, Map<String, Object>> equipMapBySlot = new HashMap<>();
                for (Map<String, Object> equip : equipList) {
                    String slot = safeStr(equip, "item_equipment_slot");
                    if (!slot.isEmpty()) equipMapBySlot.put(slot, equip);
                }
                try {
                    model.addAttribute("equipMapJson", objectMapper.writeValueAsString(equipMapBySlot));
                } catch (Exception ex) {
                    model.addAttribute("equipMapJson", "{}");
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 코디 (캐시 아이템) - 착용중 + 프리셋 1/2/3 ───────────
        try {
            JsonNode codiNode = nexonApiUtil.getCashItemEquipment(ocid);
            if (codiNode != null) {
                model.addAttribute("codiBase",    extractCodiList(codiNode, "cash_item_equipment_base"));
                model.addAttribute("codiPreset1", extractCodiList(codiNode, "cash_item_equipment_preset_1"));
                model.addAttribute("codiPreset2", extractCodiList(codiNode, "cash_item_equipment_preset_2"));
                model.addAttribute("codiPreset3", extractCodiList(codiNode, "cash_item_equipment_preset_3"));
                // 하위 호환
                model.addAttribute("codiList", extractCodiList(codiNode, "cash_item_equipment_base"));
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 유니온 기본 정보 ──────────────────────────────────
        try {
            JsonNode unionNode = nexonApiUtil.getUnion(ocid);
            if (unionNode != null) {
                model.addAttribute("unionLevel", unionNode.path("union_level").asText(""));
                model.addAttribute("unionGrade", unionNode.path("union_grade").asText(""));
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 인기도 ────────────────────────────────────────────
        try {
            JsonNode popNode = nexonApiUtil.getPopularity(ocid);
            if (popNode != null) {
                model.addAttribute("popularity", popNode.path("popularity").asText(""));
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 유니온 공격대 (raider) ────────────────────────────
        try {
            JsonNode raiderNode = nexonApiUtil.getUnionRaider(ocid);
            if (raiderNode != null) {
                // 공격대 효과 (stat 목록)
                List<String> raiderStats = new ArrayList<>();
                if (raiderNode.has("union_raider_stat")) {
                    for (JsonNode s : raiderNode.get("union_raider_stat")) {
                        raiderStats.add(s.asText());
                    }
                }
                model.addAttribute("raiderStats", raiderStats);

                // 점령 효과
                List<String> occupiedStats = new ArrayList<>();
                if (raiderNode.has("union_occupied_stat")) {
                    for (JsonNode s : raiderNode.get("union_occupied_stat")) {
                        occupiedStats.add(s.asText());
                    }
                }
                model.addAttribute("occupiedStats", occupiedStats);

                // 편성 블록 (직업 + 레벨)
                List<Map<String, Object>> unionBlocks = new ArrayList<>();
                if (raiderNode.has("union_block")) {
                    for (JsonNode b : raiderNode.get("union_block")) {
                        Map<String, Object> row = new HashMap<>();
                        row.put("blockClass", b.path("block_class").asText(""));
                        row.put("blockLevel", b.path("block_level").asText("0"));
                        unionBlocks.add(row);
                    }
                    // 레벨 내림차순 정렬
                    unionBlocks.sort((a, b) -> {
                        int la = Integer.parseInt(((String) a.get("blockLevel")).replaceAll("[^0-9]", "0"));
                        int lb = Integer.parseInt(((String) b.get("blockLevel")).replaceAll("[^0-9]", "0"));
                        return Integer.compare(lb, la);
                    });
                }
                model.addAttribute("unionBlocks", unionBlocks);
                model.addAttribute("unionBlockCount", unionBlocks.size());
            }
        } catch (Exception e) { e.printStackTrace(); }

        // ── 헥사(6차)/V매트릭스(5차)는 '개발 단계' API 키로 403(Access Denied)이라 미지원 → 정식 키 전환 시 복구 ──

        // ── 유니온 아티팩트 ────────────────────────────────────
        try {
            JsonNode artNode = nexonApiUtil.getUnionArtifact(ocid);
            if (artNode != null) {
                model.addAttribute("artifactAp", artNode.path("union_artifact_remain_ap").asInt(0));
                if (artNode.has("union_artifact_crystal")) {
                    List<Map<String, Object>> crystalList = new ArrayList<>();
                    for (JsonNode c : artNode.get("union_artifact_crystal")) {
                        // validity_flag "0" = 사용 가능(유효), "1" = 만료 → 유효한 것만 표시
                        if (!"0".equals(c.path("validity_flag").asText("0"))) continue;
                        Map<String, Object> row = new HashMap<>();
                        row.put("name",  c.path("name").asText(""));
                        row.put("level", c.path("level").asInt(0));
                        row.put("opt1",  c.path("crystal_option_name_1").asText(""));
                        row.put("opt2",  c.path("crystal_option_name_2").asText(""));
                        row.put("opt3",  c.path("crystal_option_name_3").asText(""));
                        crystalList.add(row);
                    }
                    model.addAttribute("crystalList", crystalList);
                }
                if (artNode.has("union_artifact_effect")) {
                    List<Map<String, Object>> effectList = new ArrayList<>();
                    for (JsonNode ef : artNode.get("union_artifact_effect")) {
                        String ename = ef.path("name").asText("").trim();
                        if (ename.isEmpty()) continue;
                        Map<String, Object> row = new HashMap<>();
                        row.put("name",  ename);
                        row.put("level", ef.path("level").asInt(0));
                        effectList.add(row);
                    }
                    model.addAttribute("artifactEffectList", effectList);
                }
            }
        } catch (Exception e) { e.printStackTrace(); }

        return "character/result";
    }

    // ─────────────────────────────────────────────────────────
    // 즐겨찾기 추가
    @PostMapping("/favorite/add")
    public String addFavorite(@RequestParam("charName") String charName, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";

        FavoriteDto fav = new FavoriteDto();
        fav.setMemberId(loginMember.getMemberId());
        fav.setCharName(charName);
        favoriteService.add(fav);

        try {
            String encoded = URLEncoder.encode(charName, StandardCharsets.UTF_8);
            return "redirect:/character/search?charName=" + encoded;
        } catch (Exception e) {
            return "redirect:/character/search";
        }
    }

    // ─────────────────────────────────────────────────────────
    // 즐겨찾기 삭제
    @PostMapping("/favorite/delete")
    public String deleteFavorite(@RequestParam("favId") int favId,
                                  @RequestParam(name = "charName", required = false) String charName) {
        favoriteService.delete(favId);
        if (charName != null && !charName.isBlank()) {
            try {
                return "redirect:/character/search?charName=" +
                        URLEncoder.encode(charName, StandardCharsets.UTF_8);
            } catch (Exception ignored) {}
        }
        return "redirect:/member/mypage";
    }

    // ─────────────────────────────────────────────────────────
    // 스펙 히스토리 조회
    @GetMapping("/history")
    public String history(@RequestParam(name = "charName", required = false) String charName,
                          Model model, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        if (charName == null || charName.trim().isEmpty()) return "redirect:/member/mypage";

        List<SpecHistoryDto> historyList =
                favoriteService.getSpecHistory(loginMember.getMemberId(), charName);
        model.addAttribute("historyList", historyList);
        model.addAttribute("charName", charName);
        return "character/history";
    }

    // ─────────────────────────────────────────────────────────
    // 스펙 저장 (Ajax)
    @PostMapping("/history/save")
    @ResponseBody
    public String saveSpec(@RequestParam("charName") String charName, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "fail";

        String ocid = nexonApiUtil.getOcid(charName);
        if (ocid == null) return "fail";

        JsonNode stat = nexonApiUtil.getStat(ocid);
        if (stat == null) return "fail";

        SpecHistoryDto spec = new SpecHistoryDto();
        spec.setMemberId(loginMember.getMemberId());
        spec.setCharName(charName);

        if (stat.has("final_stat")) {
            for (JsonNode s : stat.get("final_stat")) {
                String name  = s.path("stat_name").asText();
                String value = s.path("stat_value").asText();
                switch (name) {
                    case "공격력"              -> spec.setAttackPower(parseIntSafe(value));
                    case "보스 몬스터 데미지"   -> spec.setBossDmg(parseIntSafe(value));
                    case "방어율 무시"          -> spec.setIgnDef(parseIntSafe(value));
                    case "최종 데미지"          -> spec.setFinalDmg(parseIntSafe(value));
                }
            }
        }

        return favoriteService.saveSpec(spec) ? "ok" : "fail";
    }

    // ─────────────────────────────────────────────────────────
    // 코디 목록 추출 헬퍼
    private List<Map<String, Object>> extractCodiList(JsonNode root, String key) {
        List<Map<String, Object>> list = new ArrayList<>();
        if (root.has(key) && root.get(key).isArray()) {
            for (JsonNode item : root.get(key)) {
                list.add(toMap(item));
            }
        }
        return list;
    }

    // ─────────────────────────────────────────────────────────
    // 잠재능력 등급 → CSS 클래스
    private String toGradeClass(String grade) {
        if (grade == null || grade.isBlank()) return "grade-none";
        return switch (grade) {
            case "레전드리" -> "grade-legendary";
            case "유니크"   -> "grade-unique";
            case "에픽"     -> "grade-epic";
            case "레어"     -> "grade-rare";
            default         -> "grade-none";
        };
    }

    private String safeStr(Map<String, Object> m, String key) {
        Object v = m.get(key);
        return v instanceof String s ? s : "";
    }

    // 전투력 숫자 → "1억 3,345만" 형태 (억/만 단위)
    private String formatCombatPower(String value) {
        try {
            long n = Long.parseLong(value.trim());
            long eok = n / 100_000_000L;
            long man = (n % 100_000_000L) / 10_000L;
            StringBuilder sb = new StringBuilder();
            if (eok > 0) {
                sb.append(eok).append("억");
                if (man > 0) sb.append(' ').append(String.format("%,d", man)).append("만");
            } else if (man > 0) {
                sb.append(String.format("%,d", man)).append("만");
            } else {
                sb.append(String.format("%,d", n));
            }
            return sb.toString();
        } catch (Exception e) {
            return value;
        }
    }

    private int parseIntSafe(String value) {
        try {
            return (int) Double.parseDouble(value.replace("%", "").trim());
        } catch (Exception e) {
            return 0;
        }
    }

    private String toHexaTypeClass(String type) {
        if (type == null || type.isBlank()) return "type-common";
        if (type.contains("마스터리")) return "type-master";
        if (type.contains("강화"))    return "type-enhance";
        if (type.contains("스킬"))    return "type-skill";
        return "type-common";
    }

    private String toVTypeClass(String type) {
        if (type == null || type.isBlank()) return "type-common";
        if (type.contains("강화")) return "type-enhance";
        if (type.contains("특수")) return "type-master";
        return "type-common";
    }
}
