package com.mapple.controller;

import com.mapple.dto.AnnouncementDto;
import com.mapple.dto.MemberDto;
import com.mapple.service.AnnouncementService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

@Controller
@RequestMapping("/announcement")
public class AnnouncementController {

    @Autowired
    private AnnouncementService announcementService;

    private boolean isAdmin(HttpSession session) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        return m != null && "ADMIN".equals(m.getRole());
    }

    // 목록 (전체 열람)
    @GetMapping({"", "/list"})
    public String list(Model model) {
        try {
            model.addAttribute("annList", announcementService.getList());
        } catch (Exception e) {
            // announcement_tb 미생성 등 → 빈 목록으로 graceful 처리
            model.addAttribute("annList", java.util.Collections.emptyList());
            model.addAttribute("dbError", true);
        }
        return "announcement/list";
    }

    // 상세 (조회수 증가)
    @GetMapping("/detail/{id}")
    public String detail(@PathVariable("id") int id, Model model) {
        AnnouncementDto ann = announcementService.getDetail(id);
        if (ann == null) return "redirect:/announcement";
        model.addAttribute("ann", ann);
        return "announcement/detail";
    }

    // 작성 폼 (관리자)
    @GetMapping("/write")
    public String writeForm(HttpSession session) {
        if (!isAdmin(session)) return "redirect:/announcement";
        return "announcement/write";
    }

    // 작성 처리 (관리자)
    @PostMapping("/write")
    public String write(AnnouncementDto dto, HttpSession session) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        if (m == null || !"ADMIN".equals(m.getRole())) return "redirect:/announcement";
        dto.setMemberId(m.getMemberId());
        announcementService.write(dto);
        return "redirect:/announcement";
    }

    // 수정 폼 (관리자)
    @GetMapping("/edit/{id}")
    public String editForm(@PathVariable("id") int id, HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/announcement";
        AnnouncementDto ann = announcementService.findById(id);
        if (ann == null) return "redirect:/announcement";
        model.addAttribute("ann", ann);
        return "announcement/edit";
    }

    // 수정 처리 (관리자)
    @PostMapping("/edit")
    public String edit(AnnouncementDto dto, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/announcement";
        announcementService.update(dto);
        return "redirect:/announcement/detail/" + dto.getAnnouncementId();
    }

    // 삭제 (관리자)
    @PostMapping("/delete/{id}")
    public String delete(@PathVariable("id") int id, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/announcement";
        announcementService.delete(id);
        return "redirect:/announcement";
    }
}
