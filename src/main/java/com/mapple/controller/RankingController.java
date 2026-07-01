package com.mapple.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapple.util.NexonApiUtil;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.util.*;

@Controller
@RequestMapping("/ranking")
public class RankingController {

    @Autowired
    private NexonApiUtil nexonApiUtil;

    private final ObjectMapper objectMapper = new ObjectMapper();

    @SuppressWarnings("unchecked")
    private Map<String, Object> toMap(JsonNode node) {
        if (node == null || node.isNull()) return new HashMap<>();
        return objectMapper.convertValue(node, Map.class);
    }

    @GetMapping("")
    public String ranking(
            @RequestParam(name = "type",      defaultValue = "overall") String type,
            @RequestParam(name = "world",     defaultValue = "")        String world,
            @RequestParam(name = "className", defaultValue = "")        String className,
            @RequestParam(name = "page",      defaultValue = "1")       int page,
            Model model) {

        model.addAttribute("type",      type);
        model.addAttribute("world",     world);
        model.addAttribute("className", className);
        model.addAttribute("page",      page);

        try {
            // Nexon API 에는 class 파라미터 없이 호출 — Java 에서 필터링
            JsonNode data = switch (type) {
                case "union"       -> nexonApiUtil.getUnionRanking(world, page);
                case "dojang"      -> nexonApiUtil.getDojangRanking(world, className, page);
                case "theseed"     -> nexonApiUtil.getTheSeedRanking(world, page);
                case "achievement" -> nexonApiUtil.getAchievementRanking(page);
                default            -> nexonApiUtil.getOverallRanking(world, className, page);
            };

            if (data != null && data.has("ranking")) {
                List<Map<String, Object>> rankList = new ArrayList<>();
                Map<String, Integer> classCount = new LinkedHashMap<>();

                int rawCount = data.get("ranking").size();   // 넥슨 한 페이지 = 200명
                int counter = (page - 1) * 200;
                for (JsonNode r : data.get("ranking")) {
                    counter++;
                    // character_name 이 "??" 뿐인 완전 비공개는 제외
                    String charName = r.path("character_name").asText("");
                    if (charName.isBlank() || charName.replace("?", "").isBlank()) continue;

                    // 직업 필터 — sub_class_name 또는 class_name 과 일치하는 행만 포함
                    if (className != null && !className.isBlank()) {
                        String sub = r.path("sub_class_name").asText("");
                        String cls = r.path("class_name").asText("");
                        if (!className.equals(sub) && !className.equals(cls)) continue;
                    }

                    Map<String, Object> entry = toMap(r);
                    // ranking 이 숫자가 아니면 (API 가 "??" 반환) → 현재 순서로 대체
                    Object rv = entry.get("ranking");
                    if (rv == null || !rv.toString().matches("\\d+")) {
                        entry.put("ranking", counter);
                    }
                    rankList.add(entry);

                    String cls = r.path("sub_class_name").asText("");
                    if (cls.isBlank()) cls = r.path("class_name").asText("기타");
                    if (!cls.isBlank()) classCount.merge(cls, 1, Integer::sum);
                }

                List<Map.Entry<String, Integer>> classDist = new ArrayList<>(classCount.entrySet());
                classDist.sort((a, b) -> b.getValue() - a.getValue());

                model.addAttribute("rankList",   rankList);
                model.addAttribute("classDist",  classDist.stream().limit(10).toList());
                model.addAttribute("totalRanked", rankList.size());
                model.addAttribute("hasNext",     rawCount >= 200);   // 페이지가 꽉 차면 다음 페이지 존재

                if (!rankList.isEmpty() && className != null && !className.isBlank()) {
                    model.addAttribute("filterNote",
                            "'" + className + "' 필터 결과 (200명 기준): " + rankList.size() + "명");
                } else if (rankList.isEmpty() && className != null && !className.isBlank()) {
                    model.addAttribute("errorMsg",
                            "상위 200명 중 '" + className + "' 직업 캐릭터가 없습니다.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            model.addAttribute("errorMsg", "랭킹 정보를 불러오는 중 오류가 발생했습니다.");
        }

        return "ranking/list";
    }
}
