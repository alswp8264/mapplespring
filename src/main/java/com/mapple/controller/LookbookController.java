package com.mapple.controller;

import com.mapple.dto.LookbookDto;
import com.mapple.dto.MemberDto;
import com.mapple.service.LookbookService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import java.util.Map;

@Controller
@RequestMapping("/lookbook")
public class LookbookController {

    @Autowired
    private LookbookService lookbookService;

    /* ── 룩북 목록 (비로그인도 열람 가능) ── */
    @GetMapping("")
    public String list(Model model, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        int memberId = (loginMember != null) ? loginMember.getMemberId() : 0;

        model.addAttribute("lookbookList", lookbookService.getAllWithLike(memberId));
        if (loginMember != null) {
            model.addAttribute("myList", lookbookService.getMyList(memberId));
        }
        return "lookbook/list";
    }

    /* ── 좋아요 토글 (AJAX, 로그인 필요) ── */
    @PostMapping("/like")
    @ResponseBody
    public ResponseEntity<?> like(@RequestParam("lookbookId") int lookbookId,
                                  HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) {
            return ResponseEntity.status(401).body(Map.of("error", "login_required"));
        }
        Map<String, Object> result = lookbookService.toggleLike(lookbookId, loginMember.getMemberId());
        return ResponseEntity.ok(result);
    }

    /* ── 룩북 등록 (캐릭터 검색 결과에서 POST) ── */
    @PostMapping("/register")
    public String register(@RequestParam("charName")  String charName,
                           @RequestParam("charImage") String charImage,
                           @RequestParam("charClass") String charClass,
                           @RequestParam("charWorld") String charWorld,
                           @RequestParam("charLevel") int    charLevel,
                           @RequestParam(value = "title", defaultValue = "") String title,
                           HttpSession session) {

        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";

        LookbookDto dto = new LookbookDto();
        dto.setMemberId(loginMember.getMemberId());
        dto.setCharName(charName);
        dto.setCharImage(charImage);
        dto.setCharClass(charClass);
        dto.setCharWorld(charWorld);
        dto.setCharLevel(charLevel);
        dto.setTitle(title.isBlank() ? charName + "의 코디" : title);

        lookbookService.register(dto);
        return "redirect:/lookbook";
    }

    /* ── 룩북 삭제 ── */
    @PostMapping("/delete")
    public String delete(@RequestParam("lookbookId") int lookbookId,
                         HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        lookbookService.delete(lookbookId, loginMember.getMemberId());
        return "redirect:/lookbook";
    }

    /* ── 룩북 삭제 (관리자 강제 삭제) ── */
    @PostMapping("/admin/delete")
    public String adminDelete(@RequestParam("lookbookId") int lookbookId, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null || !"ADMIN".equals(loginMember.getRole())) return "redirect:/lookbook";
        lookbookService.deleteByAdmin(lookbookId);
        return "redirect:/lookbook";
    }

    /* ── 코디 분석 ── */
    @GetMapping("/analysis")
    public String analysis(Model model) {
        model.addAttribute("classStats",  lookbookService.getClassStats());
        model.addAttribute("worldStats",  lookbookService.getWorldStats());
        model.addAttribute("totalCount",  lookbookService.getTotalCount());
        model.addAttribute("recentList",  lookbookService.getAll().stream().limit(12).toList());
        return "lookbook/analysis";
    }
}
