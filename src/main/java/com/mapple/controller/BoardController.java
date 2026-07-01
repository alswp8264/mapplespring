package com.mapple.controller;

import com.mapple.dto.BoardDto;
import com.mapple.dto.BoardFileDto;
import com.mapple.dto.CommentDto;
import com.mapple.dto.MemberDto;
import com.mapple.service.BoardService;
import com.mapple.service.MemberService;
import com.mapple.service.ReportService;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;
import org.springframework.web.multipart.MultipartFile;

import java.io.File;
import java.util.ArrayList;
import java.util.List;
import java.util.UUID;

@Controller
@RequestMapping("/board")
public class BoardController {

    @Autowired
    private BoardService boardService;

    @Autowired
    private MemberService memberService;

    @Autowired
    private ReportService reportService;

    private boolean isAdmin(HttpSession session) {
        MemberDto m = (MemberDto) session.getAttribute("loginMember");
        return m != null && "ADMIN".equals(m.getRole());
    }

    // 게시판 카테고리
    public static final List<String> CATEGORIES =
            List.of("공략", "전사", "도적", "마법사", "해적", "궁수");
    // 업로드 저장 경로 (리소스 매핑 /upload/** → file:///D:/Lecture/eclipse-server/upload/)
    private static final String UPLOAD_DIR = "D:/Lecture/eclipse-server/upload/board/";

    // 업로드 파일 저장 → BoardFileDto 목록 반환
    private List<BoardFileDto> saveFiles(MultipartFile[] files) {
        List<BoardFileDto> result = new ArrayList<>();
        if (files == null) return result;
        File dir = new File(UPLOAD_DIR);
        if (!dir.exists()) dir.mkdirs();
        for (MultipartFile mf : files) {
            if (mf == null || mf.isEmpty()) continue;
            String orig = mf.getOriginalFilename();
            String ext = (orig != null && orig.contains(".")) ? orig.substring(orig.lastIndexOf('.')) : "";
            String stored = UUID.randomUUID().toString().replace("-", "") + ext;
            String ctype = mf.getContentType() == null ? "" : mf.getContentType();
            String type = ctype.startsWith("video") ? "video"
                        : ctype.startsWith("image") ? "image" : "image";
            try {
                mf.transferTo(new File(dir, stored));
                BoardFileDto f = new BoardFileDto();
                f.setFileName(stored);
                f.setOrigName(orig);
                f.setFileType(type);
                result.add(f);
            } catch (Exception e) {
                System.err.println("[BoardFile] 저장 실패: " + orig + " - " + e.getMessage());
            }
        }
        return result;
    }

    // 게시글 목록 (카테고리 토글 필터)
    @GetMapping("/list")
    public String list(@RequestParam(name = "page", defaultValue = "1") int page,
                       @RequestParam(name = "category", required = false) String category,
                       Model model) {
        if (category != null && category.isBlank()) category = null;
        model.addAttribute("boardList", boardService.getList(page, category));
        model.addAttribute("totalPage", boardService.getTotalPage(category));
        model.addAttribute("currentPage", page);
        model.addAttribute("categories", CATEGORIES);
        model.addAttribute("selectedCategory", category);
        return "board/list";
    }

    // 게시글 작성 폼
    @GetMapping("/write")
    public String writeForm(HttpSession session, Model model) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        if (memberService.isBanned(loginMember.getMemberId())) return "redirect:/board/list?msg=banned";
        model.addAttribute("categories", CATEGORIES);
        return "board/write";
    }

    // 게시글 작성 처리 (이미지/동영상 첨부 + 유튜브 링크)
    @PostMapping("/write")
    public String write(BoardDto board,
                        @RequestParam(name = "files", required = false) MultipartFile[] files,
                        @RequestParam(name = "youtubeUrls", required = false) String youtubeUrls,
                        HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        if (memberService.isBanned(loginMember.getMemberId())) return "redirect:/board/list?msg=banned";
        board.setMemberId(loginMember.getMemberId());
        if (board.getCategory() == null || board.getCategory().isBlank()) board.setCategory("공략");
        List<BoardFileDto> attachments = saveFiles(files);
        attachments.addAll(parseYoutube(youtubeUrls));
        boardService.write(board, attachments);
        return "redirect:/board/list";
    }

    // 유튜브 URL 텍스트 → 영상ID 추출하여 첨부(타입 youtube)로 변환
    private static final java.util.regex.Pattern YT_PATTERN = java.util.regex.Pattern.compile(
            "(?:youtube\\.com/(?:watch\\?v=|embed/|shorts/|live/)|youtu\\.be/)([A-Za-z0-9_-]{11})");
    private List<BoardFileDto> parseYoutube(String text) {
        List<BoardFileDto> list = new ArrayList<>();
        if (text == null || text.isBlank()) return list;
        java.util.regex.Matcher m = YT_PATTERN.matcher(text);
        while (m.find()) {
            BoardFileDto f = new BoardFileDto();
            f.setFileName(m.group(1));   // 유튜브 영상 ID
            f.setOrigName("youtube");
            f.setFileType("youtube");
            list.add(f);
        }
        return list;
    }

    // 게시글 상세 (조회수 증가 + 첨부파일)
    @GetMapping("/detail/{boardId}")
    public String detail(@PathVariable("boardId") int boardId, Model model) {
        BoardDto board = boardService.getDetail(boardId);
        if (board == null) return "redirect:/board/list";
        model.addAttribute("board", board);
        model.addAttribute("fileList", boardService.getFiles(boardId));
        model.addAttribute("commentList", boardService.getComments(boardId));
        return "board/detail";
    }

    // 게시글 수정 폼 (조회수 증가 없음)
    @GetMapping("/edit/{boardId}")
    public String editForm(@PathVariable("boardId") int boardId, Model model, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        BoardDto board = boardService.findById(boardId);
        if (board == null) return "redirect:/board/list";
        if (board.getMemberId() != loginMember.getMemberId()) return "redirect:/board/detail/" + boardId;
        model.addAttribute("board", board);
        model.addAttribute("fileList", boardService.getFiles(boardId));
        model.addAttribute("categories", CATEGORIES);
        return "board/edit";
    }

    // 게시글 수정 처리 (카테고리 변경 + 파일/유튜브 추가)
    @PostMapping("/edit")
    public String edit(BoardDto board,
                       @RequestParam(name = "files", required = false) MultipartFile[] files,
                       @RequestParam(name = "youtubeUrls", required = false) String youtubeUrls,
                       HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        boolean ok = boardService.update(board, loginMember.getMemberId());
        if (ok) {
            List<BoardFileDto> add = saveFiles(files);
            add.addAll(parseYoutube(youtubeUrls));
            boardService.addFiles(board.getBoardId(), add);
        }
        return "redirect:/board/detail/" + board.getBoardId();
    }

    // 게시글 삭제
    @PostMapping("/delete/{boardId}")
    public String delete(@PathVariable("boardId") int boardId, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        boardService.delete(boardId, loginMember.getMemberId(), loginMember.getRole());
        return "redirect:/board/list";
    }

    // 댓글 작성
    @PostMapping("/comment/write")
    public String writeComment(CommentDto comment, HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        if (memberService.isBanned(loginMember.getMemberId()))
            return "redirect:/board/detail/" + comment.getBoardId() + "?msg=banned";
        comment.setMemberId(loginMember.getMemberId());
        boardService.writeComment(comment);
        return "redirect:/board/detail/" + comment.getBoardId();
    }

    // ── 게시글 신고 ────────────────────────────────────────
    @PostMapping("/report")
    public String report(@RequestParam("boardId") int boardId,
                         @RequestParam(value = "reason", required = false) String reason,
                         HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        boolean ok = reportService.report(boardId, loginMember.getMemberId(), reason);
        return "redirect:/board/detail/" + boardId + (ok ? "?msg=reported" : "?msg=report_dup");
    }

    // ── 관리자: 신고 관리 ──────────────────────────────────
    @GetMapping("/admin/reports")
    public String reports(HttpSession session, Model model) {
        if (!isAdmin(session)) return "redirect:/";
        model.addAttribute("reportList", reportService.getPending());
        return "board/adminReports";
    }

    // 신고 승인 → 작성자 1시간 밴 + 게시글 삭제
    @PostMapping("/admin/report/approve")
    public String approveReport(@RequestParam("reportId") int reportId, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/";
        reportService.approve(reportId);
        return "redirect:/board/admin/reports";
    }

    // 신고 반려 (게시글 유지)
    @PostMapping("/admin/report/reject")
    public String rejectReport(@RequestParam("reportId") int reportId, HttpSession session) {
        if (!isAdmin(session)) return "redirect:/";
        reportService.reject(reportId);
        return "redirect:/board/admin/reports";
    }

    // 댓글 삭제
    @PostMapping("/comment/delete")
    public String deleteComment(@RequestParam("commentId") int commentId,
                                @RequestParam("boardId") int boardId,
                                HttpSession session) {
        MemberDto loginMember = (MemberDto) session.getAttribute("loginMember");
        if (loginMember == null) return "redirect:/member/login";
        boardService.deleteComment(commentId, loginMember.getMemberId(), loginMember.getRole());
        return "redirect:/board/detail/" + boardId;
    }
}
