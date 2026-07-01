package com.mapple.controller;

import java.util.*;

import com.fasterxml.jackson.databind.JsonNode;
import com.mapple.dao.NoticeThumbDao;
import com.mapple.dto.MemberDto;
import com.mapple.dto.NoticeThumbDto;
import com.mapple.service.BoardService;
import com.mapple.service.FavoriteService;
import com.mapple.util.NexonApiUtil;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    @Autowired
    private BoardService boardService;

    @Autowired
    private NexonApiUtil nexonApiUtil;

    @Autowired
    private NoticeThumbDao noticeThumbDao;

    @Autowired
    private FavoriteService favoriteService;

    // 캐릭터명 → 캐릭터 이미지 URL 메모리 캐시
    private final Map<String, String> charImageCache = new java.util.concurrent.ConcurrentHashMap<>();

    // API 결과 10분 캐시
    private static final long CACHE_TTL_MS = 10 * 60 * 1000L;
    private volatile List<Map<String, String>> cachedEventList;
    private volatile List<Map<String, String>> cachedCashList;
    private volatile List<Map<String, String>> cachedRankList;
    private volatile List<Map<String, String>> cachedDojangList;
    private volatile List<Map<String, String>> cachedUnionList;
    private volatile List<Map<String, String>> cachedUpdateList;
    private volatile long eventCacheTime;
    private volatile long cashCacheTime;
    private volatile long rankCacheTime;
    private volatile long dojangCacheTime;
    private volatile long unionCacheTime;
    private volatile long updateCacheTime;

    private boolean isFresh(long time) {
        return time > 0 && (System.currentTimeMillis() - time) < CACHE_TTL_MS;
    }

    @GetMapping("/")
    public String main(Model model, HttpSession session) {

        // 로그인 유저 즐겨찾기
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember != null) {
            try {
                model.addAttribute("favList", favoriteService.getList(loginMember.getMemberId()));
            } catch (Exception ignored) {}
        }

        // 최근 게시글 5개
        try {
            model.addAttribute("recentBoards",
                    boardService.getList(1).stream().limit(5).toList());
        } catch (Exception e) { }

        // 이벤트 목록 + 썸네일 (최대 8개) — 10분 캐시
        if (isFresh(eventCacheTime) && cachedEventList != null) {
            model.addAttribute("eventList", cachedEventList);
        } else try {
            JsonNode eventData = nexonApiUtil.getEventNotices();
            if (eventData != null && eventData.has("event_notice")) {
                List<Map<String, String>> eventList = new ArrayList<>();
                for (JsonNode node : eventData.get("event_notice")) {
                    if (eventList.size() >= 8) break;
                    String id = safeText(node, "notice_id");
                    String start = formatDate(safeText(node, "date_event_start"));
                    String end   = formatDate(safeText(node, "date_event_end"));
                    Map<String, String> m = new HashMap<>();
                    m.put("notice_id",        id);
                    m.put("title",            safeText(node, "title"));
                    m.put("date",             formatDate(safeText(node, "date")));
                    m.put("date_event_start", start);
                    m.put("date_event_end",   end);
                    m.put("date_short",       shortRange(start, end));
                    m.put("thumbnail",        fetchThumb("ev-" + id, id, true));
                    eventList.add(m);
                }
                if (!eventList.isEmpty()) { cachedEventList = eventList; eventCacheTime = System.currentTimeMillis(); }
                model.addAttribute("eventList", eventList);
            }
        } catch (Exception e) { }

        // 캐시샵 목록 + 썸네일 (최대 8개) — 10분 캐시
        if (isFresh(cashCacheTime) && cachedCashList != null) {
            model.addAttribute("cashList", cachedCashList);
        } else try {
            JsonNode cashData = nexonApiUtil.getCashShopNotices();
            if (cashData != null && cashData.has("cashshop_notice")) {
                List<Map<String, String>> cashList = new ArrayList<>();
                for (JsonNode node : cashData.get("cashshop_notice")) {
                    if (cashList.size() >= 8) break;
                    String id    = safeText(node, "notice_id");
                    String start = formatDate(safeText(node, "date_sale_start"));
                    String end   = formatDate(safeText(node, "date_sale_end"));
                    Map<String, String> m = new HashMap<>();
                    m.put("notice_id",       id);
                    m.put("title",           safeText(node, "title"));
                    m.put("date",            formatDate(safeText(node, "date")));
                    m.put("date_sale_start", start);
                    m.put("date_sale_end",   end);
                    m.put("date_short",      shortRange(start, end));
                    m.put("thumbnail",       fetchThumb("cs-" + id, id, false));
                    cashList.add(m);
                }
                if (!cashList.isEmpty()) { cachedCashList = cashList; cashCacheTime = System.currentTimeMillis(); }
                model.addAttribute("cashList", cashList);
            }
        } catch (Exception e) { }

        // 종합 랭킹 TOP 20 — 10분 캐시
        List<Map<String, String>> rankList = new ArrayList<>();
        if (isFresh(rankCacheTime) && cachedRankList != null) {
            rankList = cachedRankList;
            model.addAttribute("rankList", rankList);
        } else try {
            for (int page = 1; page <= 2 && rankList.size() < 20; page++) {
                JsonNode rankData = nexonApiUtil.getOverallRanking(null, null, page);
                if (rankData == null || !rankData.has("ranking")) break;
                for (JsonNode node : rankData.get("ranking")) {
                    if (rankList.size() >= 20) break;
                    String charName = safeText(node, "character_name");
                    if (charName.isBlank() || charName.replace("?", "").isBlank()) continue;
                    Map<String, String> m = new HashMap<>();
                    m.put("ranking",          safeText(node, "ranking"));
                    m.put("character_name",   charName);
                    m.put("world_name",       safeText(node, "world_name"));
                    m.put("class_name",       safeText(node, "class_name").isBlank()
                                              ? safeText(node, "class") : safeText(node, "class_name"));
                    m.put("character_level",  safeText(node, "character_level"));
                    m.put("character_image",  "");   // 이미지는 랭킹 로딩 후 마지막에 보강 (레이트리밋 보호)
                    m.put("guild_name",       safeText(node, "character_guildname"));
                    rankList.add(m);
                }
            }
            if (!rankList.isEmpty()) { cachedRankList = rankList; rankCacheTime = System.currentTimeMillis(); }
            model.addAttribute("rankList", rankList);
        } catch (Exception e) { }

        // 무릉도장 랭킹 TOP 10 — 10분 캐시
        if (isFresh(dojangCacheTime) && cachedDojangList != null) {
            model.addAttribute("dojangList", cachedDojangList);
        } else try {
            List<Map<String, String>> dojangList = new ArrayList<>();
            JsonNode dojangData = nexonApiUtil.getDojangRanking(null, null, 1);
            if (dojangData != null && dojangData.has("ranking")) {
                for (JsonNode node : dojangData.get("ranking")) {
                    if (dojangList.size() >= 10) break;
                    String charName = safeText(node, "character_name");
                    if (charName.isBlank() || charName.replace("?", "").isBlank()) continue;
                    Map<String, String> m = new HashMap<>();
                    m.put("ranking",         safeText(node, "ranking"));
                    m.put("character_name",  charName);
                    m.put("world_name",      safeText(node, "world_name"));
                    m.put("class_name",      safeText(node, "class_name"));
                    m.put("character_level", safeText(node, "character_level"));
                    m.put("dojang_floor",    safeText(node, "dojang_floor"));
                    dojangList.add(m);
                }
            }
            if (!dojangList.isEmpty()) { cachedDojangList = dojangList; dojangCacheTime = System.currentTimeMillis(); }
            model.addAttribute("dojangList", dojangList);
        } catch (Exception e) { }

        // 유니온 랭킹 TOP 10 — 10분 캐시
        if (isFresh(unionCacheTime) && cachedUnionList != null) {
            model.addAttribute("unionList", cachedUnionList);
        } else try {
            List<Map<String, String>> unionList = new ArrayList<>();
            JsonNode unionData = nexonApiUtil.getUnionRanking(null, 1);
            if (unionData != null && unionData.has("ranking")) {
                for (JsonNode node : unionData.get("ranking")) {
                    if (unionList.size() >= 10) break;
                    String charName = safeText(node, "character_name");
                    if (charName.isBlank() || charName.replace("?", "").isBlank()) continue;
                    Map<String, String> m = new HashMap<>();
                    m.put("ranking",         safeText(node, "ranking"));
                    m.put("character_name",  charName);
                    m.put("world_name",      safeText(node, "world_name"));
                    m.put("union_level",     safeText(node, "union_level"));
                    unionList.add(m);
                }
            }
            if (!unionList.isEmpty()) { cachedUnionList = unionList; unionCacheTime = System.currentTimeMillis(); }
            model.addAttribute("unionList", unionList);
        } catch (Exception e) { }

        // 패치노트 최신 3개 — 10분 캐시
        if (isFresh(updateCacheTime) && cachedUpdateList != null) {
            model.addAttribute("updateList", cachedUpdateList);
        } else try {
            List<Map<String, String>> updateList = new ArrayList<>();
            JsonNode updateData = nexonApiUtil.getUpdateNotices();
            if (updateData != null && updateData.has("update_notice")) {
                for (JsonNode node : updateData.get("update_notice")) {
                    if (updateList.size() >= 5) break;
                    Map<String, String> m = new HashMap<>();
                    m.put("notice_id", safeText(node, "notice_id"));
                    m.put("title",     safeText(node, "title"));
                    m.put("date",      formatDate(safeText(node, "date")));
                    updateList.add(m);
                }
            }
            if (!updateList.isEmpty()) { cachedUpdateList = updateList; updateCacheTime = System.currentTimeMillis(); }
            model.addAttribute("updateList", updateList);
        } catch (Exception e) { }

        // ── 인기 캐릭터 이미지는 랭킹 로딩이 끝난 뒤 맨 마지막에 보강 ──
        //    (이미지 조회가 레이트리밋을 먼저 소진해 무릉/유니온 랭킹을 굶기지 않도록 순서 분리)
        try {
            for (Map<String, String> m : rankList) {
                boolean cached = charImageCache.containsKey(m.get("character_name"));
                m.put("character_image", fetchCharImage(m.get("character_name")));
                if (!cached) {   // 신규 조회만 살짝 텀 — 캐시된 건 즉시
                    try { Thread.sleep(120); } catch (InterruptedException ignored) {}
                }
            }
        } catch (Exception e) { }

        return "common/main";
    }

    // 캐릭터명 → 캐릭터 이미지 URL (OCID→기본정보 조회). 성공 시 메모리 캐시
    private String fetchCharImage(String charName) {
        if (charName == null || charName.isBlank()) return "";
        String cached = charImageCache.get(charName);
        if (cached != null) return cached;
        try {
            String ocid = nexonApiUtil.getOcid(charName);
            if (ocid != null) {
                JsonNode basic = nexonApiUtil.getBasicInfo(ocid);
                if (basic != null) {
                    String img = safeText(basic, "character_image");
                    if (!img.isBlank()) {
                        charImageCache.put(charName, img);   // 성공만 캐시 (실패는 다음에 재시도)
                        return img;
                    }
                }
            }
        } catch (Exception e) {
            System.err.println("[CharImage] 로드 실패 " + charName + ": " + e.getMessage());
        }
        return "";
    }

    // DB에 저장된 썸네일 우선 반환, 없으면 API 호출 후 DB 저장
    private String fetchThumb(String cacheKey, String noticeId, boolean isEvent) {
        String type = isEvent ? "event" : "cashshop";
        // 1. DB 조회
        try {
            String saved = noticeThumbDao.findThumbnail(noticeId, type);
            if (saved != null && !saved.isBlank()) return saved;
        } catch (Exception e) { /* DB 오류 무시 후 API 시도 */ }

        // 2. API 호출
        try {
            Thread.sleep(300);
            JsonNode detail = isEvent
                    ? nexonApiUtil.getEventNoticeDetail(noticeId)
                    : nexonApiUtil.getCashShopNoticeDetail(noticeId);
            if (detail != null) {
                String thumb = safeText(detail, "thumbnail");
                if (thumb.isBlank()) {
                    String contents = safeText(detail, "contents");
                    java.util.regex.Matcher m = java.util.regex.Pattern
                            .compile("<img[^>]+src=[\"']([^\"']+)[\"']", java.util.regex.Pattern.CASE_INSENSITIVE)
                            .matcher(contents);
                    if (m.find()) thumb = m.group(1);
                }
                if (!thumb.isBlank()) {
                    // 3. DB 저장
                    try {
                        NoticeThumbDto dto = new NoticeThumbDto();
                        dto.setNoticeId(noticeId);
                        dto.setNoticeType(type);
                        dto.setThumbnail(thumb);
                        noticeThumbDao.insert(dto);
                    } catch (Exception e) { /* 저장 실패해도 반환은 계속 */ }
                    return thumb;
                }
            }
        } catch (Exception e) {
            System.err.println("[Thumb] 로드 실패 " + cacheKey + ": " + e.getMessage());
        }
        return "";
    }

    // 2026-05-14T10:00+09:00 → 2026.05.14
    private String formatDate(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return "";
        int tIdx = dateStr.indexOf('T');
        if (tIdx > 0) dateStr = dateStr.substring(0, tIdx);
        return dateStr.replace("-", ".");
    }

    // "2026.06.18" → "6/18",  range: "6/18 ~ 7/22"
    private String shortDate(String d) {
        if (d == null || d.isEmpty()) return "";
        String[] p = d.split("\\.");
        if (p.length >= 3) {
            try { return Integer.parseInt(p[1]) + "/" + Integer.parseInt(p[2]); }
            catch (NumberFormatException ignored) { }
        }
        return d;
    }

    private String shortRange(String start, String end) {
        String s = shortDate(start);
        String e = shortDate(end);
        if (s.isEmpty()) return e;
        if (e.isEmpty()) return s;
        return s + " ~ " + e;
    }

    private String safeText(JsonNode node, String field) {
        if (node == null || !node.has(field) || node.get(field).isNull()) return "";
        return node.get(field).asText("");
    }
}
