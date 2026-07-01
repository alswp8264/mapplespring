package com.mapple.controller;

import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapple.dto.MemberDto;
import com.mapple.service.FavoriteService;
import com.mapple.service.MemberService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.ResponseEntity;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.client.RestTemplate;

import java.util.*;
import java.util.stream.Collectors;

@Controller
@RequestMapping("/member")
public class MemberController {

    @Autowired
    private MemberService memberService;

    @Autowired
    private FavoriteService favoriteService;

    // 회원가입 폼
    @GetMapping("/join")
    public String joinForm() {
        return "member/join";
    }

    // 회원가입 처리
    @PostMapping("/join")
    public String join(MemberDto member, Model model) {
        boolean result = memberService.join(member);
        if (!result) {
            model.addAttribute("msg", "이미 사용 중인 아이디입니다.");
            return "member/join";
        }
        return "redirect:/member/login";
    }

    // 아이디 중복 확인 (Ajax)
    @GetMapping("/checkId")
    @ResponseBody
    public String checkId(@RequestParam("loginId") String loginId) {
        return memberService.isLoginIdDuplicate(loginId) ? "duplicate" : "ok";
    }

    // 로그인 폼
    @GetMapping("/login")
    public String loginForm() {
        return "member/login";
    }

    // 로그인 처리
    @PostMapping("/login")
    public String login(@RequestParam("loginId") String loginId,
                        @RequestParam("password") String password,
                        HttpSession session, Model model) {
        MemberDto member = memberService.login(loginId, password);
        if (member == null) {
            model.addAttribute("msg", "아이디 또는 비밀번호가 올바르지 않습니다.");
            return "member/login";
        }
        session.setAttribute("loginMember", member);
        return "redirect:/";
    }

    // 로그아웃
    @GetMapping("/logout")
    public String logout(HttpSession session) {
        session.invalidate();
        return "redirect:/";
    }

    // 마이페이지
    @GetMapping("/mypage")
    public String mypage(HttpSession session, Model model) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        model.addAttribute("member", memberService.findById(loginMember.getMemberId()));
        model.addAttribute("favList", favoriteService.getList(loginMember.getMemberId()));
        return "member/mypage";
    }

    // 회원 정보 수정
    @PostMapping("/update")
    public String update(MemberDto member, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        member.setMemberId(loginMember.getMemberId());
        memberService.update(member);
        session.setAttribute("loginMember", memberService.findById(loginMember.getMemberId()));
        return "redirect:/member/mypage";
    }

    // 비밀번호 변경
    @PostMapping("/updatePw")
    public String updatePw(@RequestParam("currentPw") String currentPw,
                           @RequestParam("newPw") String newPw,
                           HttpSession session, Model model) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";

        boolean result = memberService.updatePassword(loginMember.getMemberId(), currentPw, newPw);
        if (!result) {
            model.addAttribute("msg", "현재 비밀번호가 올바르지 않습니다.");
            model.addAttribute("member", memberService.findById(loginMember.getMemberId()));
            model.addAttribute("favList", favoriteService.getList(loginMember.getMemberId()));
            return "member/mypage";
        }
        session.invalidate();
        return "redirect:/member/login";
    }

    // 회원 탈퇴
    @PostMapping("/delete")
    public String delete(@RequestParam("password") String password,
                         HttpSession session, Model model) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";

        boolean result = memberService.delete(loginMember.getMemberId(), password);
        if (!result) {
            model.addAttribute("msg", "비밀번호가 올바르지 않습니다.");
            model.addAttribute("member", memberService.findById(loginMember.getMemberId()));
            model.addAttribute("favList", favoriteService.getList(loginMember.getMemberId()));
            return "member/mypage";
        }
        session.invalidate();
        return "redirect:/";
    }

    // 얼굴 등록 — 브라우저 캡처 이미지 → Python /face/encode → DB 저장
    @PostMapping("/face-register")
    @ResponseBody
    public Map<String, Object> faceRegister(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        try {
            RestTemplate rt = new RestTemplate();
            Map<String, Object> pyReq = new HashMap<>();
            pyReq.put("image", body.get("image"));
            @SuppressWarnings("unchecked")
            Map<String, Object> pyRes = rt.postForObject("http://localhost:5001/face/encode", pyReq, Map.class);

            if (pyRes == null || !Boolean.TRUE.equals(pyRes.get("success"))) {
                result.put("success", false);
                result.put("message", pyRes != null ? pyRes.get("message") : "Python 서버 오류");
                return result;
            }
            String encodingJson = new ObjectMapper().writeValueAsString(pyRes.get("encoding"));
            memberService.registerFace(loginMember.getMemberId(), encodingJson);
            result.put("success", true);
            result.put("message", "얼굴 등록 완료!");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "등록 오류: " + e.getMessage());
        }
        return result;
    }

    // 얼굴 등록 (다각도) — 정면/좌/우 3장 → 각각 인코딩하여 배열로 저장
    @PostMapping("/face-register-multi")
    @ResponseBody
    public Map<String, Object> faceRegisterMulti(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        try {
            @SuppressWarnings("unchecked")
            List<String> images = (List<String>) body.get("images");
            if (images == null || images.size() < 3) {
                result.put("success", false);
                result.put("message", "정면·좌·우 3장이 필요합니다.");
                return result;
            }
            // 3장 한 번에 병렬 encode 요청
            RestTemplate rt = new RestTemplate();
            Map<String, Object> pyReq = new HashMap<>();
            pyReq.put("images", images);
            @SuppressWarnings("unchecked")
            Map<String, Object> pyRes = rt.postForObject("http://localhost:5001/face/encode-multi", pyReq, Map.class);
            if (pyRes == null || !Boolean.TRUE.equals(pyRes.get("success"))) {
                result.put("success", false);
                result.put("message", pyRes != null ? pyRes.get("message") : "Python 서버 오류");
                return result;
            }
            @SuppressWarnings("unchecked")
            List<Object> encodings = (List<Object>) pyRes.get("encodings");
            // [[정면128],[좌128],[우128]] 형태로 저장
            String encodingJson = new ObjectMapper().writeValueAsString(encodings);
            memberService.registerFace(loginMember.getMemberId(), encodingJson);
            result.put("success", true);
            result.put("message", "얼굴 등록 완료! (정면·좌·우 3장)");
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "등록 오류: " + e.getMessage());
        }
        return result;
    }

    // 얼굴 인코딩 삭제
    @PostMapping("/face-delete")
    @ResponseBody
    public Map<String, Object> faceDelete(HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) {
            result.put("success", false);
            result.put("message", "로그인이 필요합니다.");
            return result;
        }
        boolean ok = memberService.deleteFace(loginMember.getMemberId());
        result.put("success", ok);
        result.put("message", ok ? "얼굴 등록이 삭제되었습니다." : "삭제 실패");
        return result;
    }

    // 얼굴 로그인 — 브라우저 이미지 + DB 후보 → Python /face/verify
    @PostMapping("/face-login")
    @ResponseBody
    public Map<String, Object> faceLogin(@RequestBody Map<String, Object> body, HttpSession session) {
        Map<String, Object> result = new HashMap<>();
        try {
            List<MemberDto> faceMembers = memberService.findAllWithFace();
            ObjectMapper mapper = new ObjectMapper();

            List<Map<String, Object>> candidates = new ArrayList<>();
            for (MemberDto m : faceMembers) {
                Map<String, Object> c = new HashMap<>();
                c.put("memberId", m.getMemberId());
                c.put("encoding", mapper.readValue(m.getFaceEncoding(), List.class));
                candidates.add(c);
            }

            if (candidates.isEmpty()) {
                result.put("success", false);
                result.put("message", "등록된 얼굴이 없습니다.");
                return result;
            }

            Map<String, Object> pyReq = new HashMap<>();
            pyReq.put("image",      body.get("image"));
            pyReq.put("candidates", candidates);

            RestTemplate rt = new RestTemplate();
            @SuppressWarnings("unchecked")
            Map<String, Object> pyRes = rt.postForObject("http://localhost:5001/face/verify", pyReq, Map.class);

            if (pyRes != null && Boolean.TRUE.equals(pyRes.get("success"))) {
                int memberId = ((Number) pyRes.get("memberId")).intValue();
                session.setAttribute("loginMember", memberService.findById(memberId));
                result.put("success", true);
            } else {
                result.put("success", false);
                result.put("message", pyRes != null ? pyRes.get("message") : "Python 서버 오류");
            }
        } catch (Exception e) {
            result.put("success", false);
            result.put("message", "오류: " + e.getMessage());
        }
        return result;
    }

    // ── 아이디 / 비밀번호 찾기 ──────────────────────────────
    @GetMapping("/findId")
    public String findIdForm() { return "member/findId"; }

    @PostMapping("/findId")
    public String findId(@RequestParam("name") String name,
                         @RequestParam("email") String email, Model model) {
        String loginId = memberService.findLoginId(name.trim(), email.trim());
        if (loginId == null) model.addAttribute("error", "일치하는 회원이 없습니다. 이름과 이메일을 확인해 주세요.");
        else                 model.addAttribute("foundId", maskId(loginId));
        return "member/findId";
    }

    @GetMapping("/findPw")
    public String findPwForm() { return "member/findPw"; }

    // 1단계: 본인확인
    @PostMapping("/findPw/verify")
    public String findPwVerify(@RequestParam("loginId") String loginId,
                               @RequestParam("name") String name,
                               @RequestParam("email") String email,
                               HttpSession session, Model model) {
        MemberDto m = memberService.verifyForPwReset(loginId.trim(), name.trim(), email.trim());
        if (m == null) {
            model.addAttribute("error", "일치하는 회원이 없습니다. (소셜 로그인 계정은 사용할 수 없습니다)");
            return "member/findPw";
        }
        session.setAttribute("pwResetMemberId", m.getMemberId());
        model.addAttribute("verified", true);
        model.addAttribute("loginId", loginId);
        return "member/findPw";
    }

    // 2단계: 새 비밀번호 설정
    @PostMapping("/findPw/reset")
    public String findPwReset(@RequestParam("newPw") String newPw, HttpSession session, Model model) {
        Object idObj = session.getAttribute("pwResetMemberId");
        if (idObj == null) {
            model.addAttribute("error", "본인확인이 필요합니다. 처음부터 다시 시도해 주세요.");
            return "member/findPw";
        }
        memberService.resetPassword((int) idObj, newPw);
        session.removeAttribute("pwResetMemberId");
        return "redirect:/member/login?msg=pw_reset";
    }

    private String maskId(String id) {
        if (id == null || id.length() <= 2) return id;
        return id.substring(0, 2) + "*".repeat(id.length() - 2);
    }

    // ── 얼굴 라이브니스 — 랜드마크 좌표 프록시 → Python /face/landmarks ──
    @PostMapping("/face-landmarks")
    @ResponseBody
    public Map<String, Object> faceLandmarks(@RequestBody Map<String, Object> body) {
        try {
            RestTemplate rt = new RestTemplate();
            Map<String, Object> pyReq = new HashMap<>();
            pyReq.put("image", body.get("image"));
            @SuppressWarnings("unchecked")
            Map<String, Object> pyRes = rt.postForObject("http://localhost:5001/face/landmarks", pyReq, Map.class);
            return pyRes != null ? pyRes : Map.of("success", false);
        } catch (Exception e) {
            return Map.of("success", false, "message", e.getMessage());
        }
    }

    // ── 관리자 ─────────────────────────────────────────────
    // 회원 목록 / 검색 (관리자 전용)
    @GetMapping("/admin/list")
    public String adminList(@RequestParam(name = "keyword", required = false) String keyword,
                            @RequestParam(name = "role", required = false) String role,
                            HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/";
        boolean hasFilter = (keyword != null && !keyword.isBlank()) || (role != null && !role.isBlank());
        model.addAttribute("memberList", hasFilter ? memberService.searchMembers(keyword, role) : memberService.findAll());
        model.addAttribute("keyword", keyword);
        model.addAttribute("roleFilter", role);
        return "member/adminList";
    }

    // 관리자 — 벤 해제
    @PostMapping("/admin/unban/{memberId}")
    public String adminUnban(@PathVariable("memberId") int memberId, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/";
        memberService.unban(memberId);
        return "redirect:/member/admin/list";
    }

    // 관리자 — 회원 강제 삭제 (자기 자신/다른 관리자 보호)
    @PostMapping("/admin/delete/{memberId}")
    public String adminDelete(@PathVariable("memberId") int memberId, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null || !"ADMIN".equals(loginMember.getRole())) return "redirect:/";
        MemberDto target = memberService.findById(memberId);
        if (target != null && !"ADMIN".equals(target.getRole())
                && target.getMemberId() != loginMember.getMemberId()) {
            memberService.deleteByAdmin(memberId);
        }
        return "redirect:/member/admin/list";
    }

    private boolean isAdmin(HttpSession session) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        return m != null && "ADMIN".equals(m.getRole());
    }
}
