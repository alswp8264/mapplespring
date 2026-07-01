package com.mapple.controller;

import com.mapple.dto.InquiryDto;
import com.mapple.dto.MemberDto;
import com.mapple.service.InquiryService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import jakarta.servlet.http.HttpSession;

@Controller
@RequestMapping("/inquiry")
public class InquiryController {

    @Autowired InquiryService inquiryService;

    // ── 문의 작성 폼 ──────────────────────────────────────────
    @GetMapping("/write")
    public String writeForm(HttpSession session) {
        if (session.getAttribute("loginMember") == null) return "redirect:/member/login";
        return "inquiry/write";
    }

    @PostMapping("/write")
    public String write(@RequestParam("title") String title,
                        @RequestParam("content") String content,
                        HttpSession session) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        if (m == null) return "redirect:/member/login";
        InquiryDto dto = new InquiryDto();
        dto.setMemberId(m.getMemberId());
        dto.setTitle(title);
        dto.setContent(content);
        inquiryService.write(dto);
        return "redirect:/inquiry/my";
    }

    // ── 내 문의 목록 ──────────────────────────────────────────
    @GetMapping("/my")
    public String myList(HttpSession session, Model model) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        if (m == null) return "redirect:/member/login";
        model.addAttribute("list", inquiryService.getMyList(m.getMemberId()));
        return "inquiry/my";
    }

    // ── 관리자: 전체 문의 목록 ────────────────────────────────
    @GetMapping("/admin/list")
    public String adminList(HttpSession session, Model model) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        if (m == null || !"ADMIN".equals(m.getRole())) return "redirect:/";
        model.addAttribute("list", inquiryService.getAll());
        return "inquiry/admin_list";
    }

    // ── 관리자: 문의 상세 + 답변 ──────────────────────────────
    @GetMapping("/admin/detail/{id}")
    public String adminDetail(@PathVariable("id") int id, HttpSession session, Model model) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        if (m == null || !"ADMIN".equals(m.getRole())) return "redirect:/";
        model.addAttribute("inquiry", inquiryService.getById(id));
        return "inquiry/admin_detail";
    }

    @PostMapping("/admin/answer")
    public String answer(@RequestParam("inquiryId") int inquiryId,
                         @RequestParam("answer") String answer,
                         HttpSession session) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        if (m == null || !"ADMIN".equals(m.getRole())) return "redirect:/";
        InquiryDto dto = new InquiryDto();
        dto.setInquiryId(inquiryId);
        dto.setAnswer(answer);
        inquiryService.answer(dto);
        return "redirect:/inquiry/admin/list";
    }
}
