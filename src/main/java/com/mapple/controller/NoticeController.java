package com.mapple.controller;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import com.fasterxml.jackson.databind.JsonNode;
import com.mapple.dao.NoticeThumbDao;
import com.mapple.util.NexonApiUtil;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
@RequestMapping("/notice")
public class NoticeController {

    @Autowired
    private NexonApiUtil nexonApiUtil;

    @Autowired
    private NoticeThumbDao noticeThumbDao;

    /* ───────────── 이벤트 목록 ───────────── */
    @GetMapping("/event")
    public String eventList(Model model) {
        try {
            JsonNode data = nexonApiUtil.getEventNotices();
            if (data != null && data.has("event_notice")) {
                List<Map<String, String>> list = new ArrayList<>();
                for (JsonNode node : data.get("event_notice")) {
                    list.add(extractEventFields(node));
                }
                model.addAttribute("eventList", list);
            }
        } catch (Exception e) { }
        return "notice/eventList";
    }

    /* ───────────── 이벤트 상세 ───────────── */
    @GetMapping("/event/detail")
    public String eventDetail(@RequestParam(name = "noticeId", required = false) String noticeId,
                              Model model, HttpServletRequest request) {
        if (noticeId == null || noticeId.isBlank()) return "redirect:/notice/event";
        try {
            JsonNode data = nexonApiUtil.getEventNoticeDetail(noticeId);
            if (data != null) {
                model.addAttribute("notice", extractEventFields(data));
                request.setAttribute("noticeContents", safeText(data, "contents"));
            }
        } catch (Exception e) { }
        return "notice/eventDetail";
    }

    /* ───────────── 캐시샵 목록 ───────────── */
    @GetMapping("/cashshop")
    public String cashShopList(Model model) {
        try {
            JsonNode data = nexonApiUtil.getCashShopNotices();
            if (data != null && data.has("cashshop_notice")) {
                List<Map<String, String>> list = new ArrayList<>();
                for (JsonNode node : data.get("cashshop_notice")) {
                    list.add(extractCashFields(node));
                }
                model.addAttribute("cashList", list);
            }
        } catch (Exception e) { }
        return "notice/cashShopList";
    }

    /* ───────────── 캐시샵 상세 ───────────── */
    @GetMapping("/cashshop/detail")
    public String cashShopDetail(@RequestParam(name = "noticeId", required = false) String noticeId,
                                 Model model, HttpServletRequest request) {
        if (noticeId == null || noticeId.isBlank()) return "redirect:/notice/cashshop";
        try {
            JsonNode data = nexonApiUtil.getCashShopNoticeDetail(noticeId);
            if (data != null) {
                model.addAttribute("notice", extractCashFields(data));
                request.setAttribute("noticeContents", safeText(data, "contents"));
            }
        } catch (Exception e) { }
        return "notice/cashShopDetail";
    }

    /* ───────────── 업데이트(패치노트) 목록 ───────────── */
    @GetMapping("/update")
    public String updateList(Model model) {
        try {
            JsonNode data = nexonApiUtil.getUpdateNotices();
            if (data != null && data.has("update_notice")) {
                List<Map<String, String>> list = new ArrayList<>();
                for (JsonNode node : data.get("update_notice")) {
                    list.add(extractUpdateFields(node));
                }
                model.addAttribute("updateList", list);
            }
        } catch (Exception e) { }
        return "notice/updateList";
    }

    /* ───────────── 업데이트(패치노트) 상세 ───────────── */
    @GetMapping("/update/detail")
    public String updateDetail(@RequestParam(name = "noticeId", required = false) String noticeId,
                               Model model, HttpServletRequest request) {
        if (noticeId == null || noticeId.isBlank()) return "redirect:/notice/update";
        try {
            JsonNode data = nexonApiUtil.getUpdateNoticeDetail(noticeId);
            if (data != null) {
                model.addAttribute("notice", extractUpdateFields(data));
                request.setAttribute("noticeContents", safeText(data, "contents"));
            }
        } catch (Exception e) { }
        return "notice/updateDetail";
    }

    /* ───────────── 필드 추출 헬퍼 ───────────── */
    private Map<String, String> extractUpdateFields(JsonNode node) {
        Map<String, String> m = new HashMap<>();
        m.put("notice_id", safeText(node, "notice_id"));
        m.put("title",     safeText(node, "title"));
        m.put("date",      formatDate(safeText(node, "date")));
        m.put("url",       safeText(node, "url"));
        return m;
    }

    private Map<String, String> extractEventFields(JsonNode node) {
        Map<String, String> m = new HashMap<>();
        String id = safeText(node, "notice_id");
        m.put("notice_id",        id);
        m.put("title",            safeText(node, "title"));
        m.put("date",             formatDate(safeText(node, "date")));
        m.put("date_event_start", formatDate(safeText(node, "date_event_start")));
        m.put("date_event_end",   formatDate(safeText(node, "date_event_end")));
        m.put("url",              safeText(node, "url"));
        m.put("thumbnail",        dbThumb(id, "event"));
        return m;
    }

    private Map<String, String> extractCashFields(JsonNode node) {
        Map<String, String> m = new HashMap<>();
        String id = safeText(node, "notice_id");
        m.put("notice_id",       id);
        m.put("title",           safeText(node, "title"));
        m.put("date",            formatDate(safeText(node, "date")));
        m.put("date_sale_start", formatDate(safeText(node, "date_sale_start")));
        m.put("date_sale_end",   formatDate(safeText(node, "date_sale_end")));
        m.put("url",             safeText(node, "url"));
        m.put("thumbnail",       dbThumb(id, "cashshop"));
        return m;
    }

    private String dbThumb(String noticeId, String type) {
        try {
            String thumb = noticeThumbDao.findThumbnail(noticeId, type);
            return (thumb != null && !thumb.isBlank()) ? thumb : "";
        } catch (Exception e) { return ""; }
    }

    // 2026-05-14T10:00+09:00 → 2026.05.14
    private String formatDate(String dateStr) {
        if (dateStr == null || dateStr.isEmpty()) return "";
        int tIdx = dateStr.indexOf('T');
        if (tIdx > 0) dateStr = dateStr.substring(0, tIdx);
        return dateStr.replace("-", ".");
    }

    private String safeText(JsonNode node, String field) {
        if (node == null || !node.has(field) || node.get(field).isNull()) return "";
        return node.get(field).asText("");
    }
}
