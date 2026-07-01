package com.mapple.service;

import com.mapple.dao.BoardDao;
import com.mapple.dao.BoardFileDao;
import com.mapple.dao.CommentDao;
import com.mapple.dto.BoardDto;
import com.mapple.dto.BoardFileDto;
import com.mapple.dto.CommentDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class BoardService {

    @Autowired
    private BoardDao boardDao;

    @Autowired
    private BoardFileDao boardFileDao;

    @Autowired
    private CommentDao commentDao;

    private static final int PAGE_SIZE = 10;

    // 게시글 작성 (첨부파일 포함)
    @Transactional
    public boolean write(BoardDto board, List<BoardFileDto> files) {
        boardDao.insert(board);                 // selectKey 로 board.boardId 채워짐
        if (files != null) {
            for (BoardFileDto f : files) {
                f.setBoardId(board.getBoardId());
                boardFileDao.insert(f);
            }
        }
        return board.getBoardId() > 0;
    }

    // 하위호환 (카테고리 없이)
    public List<BoardDto> getList(int page) { return getList(page, null); }
    public int getTotalPage() { return getTotalPage(null); }

    // 게시글 목록 (카테고리 필터)
    public List<BoardDto> getList(int page, String category) {
        Map<String, Object> params = new HashMap<>();
        params.put("offset", (page - 1) * PAGE_SIZE);
        params.put("pageSize", PAGE_SIZE);
        params.put("category", category);
        return boardDao.findAll(params);
    }

    // 전체 페이지 수 (카테고리 필터, 최소 1 반환)
    public int getTotalPage(String category) {
        int total = boardDao.count(category);
        if (total == 0) return 1;
        return (int) Math.ceil((double) total / PAGE_SIZE);
    }

    // 게시글 첨부파일
    public List<BoardFileDto> getFiles(int boardId) {
        return boardFileDao.findByBoardId(boardId);
    }

    // 첨부파일 추가 (수정 시)
    @Transactional
    public void addFiles(int boardId, List<BoardFileDto> files) {
        if (files == null) return;
        for (BoardFileDto f : files) {
            f.setBoardId(boardId);
            boardFileDao.insert(f);
        }
    }

    // 게시글 상세 조회 + 조회수 증가
    @Transactional
    public BoardDto getDetail(int boardId) {
        boardDao.updateViewCnt(boardId);
        return boardDao.findById(boardId);
    }

    // 게시글 단순 조회 (조회수 증가 없음 - 수정 폼 등에서 사용)
    public BoardDto findById(int boardId) {
        return boardDao.findById(boardId);
    }

    // 게시글 수정
    @Transactional
    public boolean update(BoardDto board, int loginMemberId) {
        BoardDto origin = boardDao.findById(board.getBoardId());
        if (origin == null || origin.getMemberId() != loginMemberId) {
            return false;
        }
        return boardDao.update(board) > 0;
    }

    // 게시글 삭제 (본인 또는 관리자)
    @Transactional
    public boolean delete(int boardId, int loginMemberId, String role) {
        BoardDto origin = boardDao.findById(boardId);
        if (origin == null) return false;
        if ("ADMIN".equals(role) || origin.getMemberId() == loginMemberId) {
            return boardDao.delete(boardId) > 0;
        }
        return false;
    }

    // 댓글 작성
    @Transactional
    public boolean writeComment(CommentDto comment) {
        return commentDao.insert(comment) > 0;
    }

    // 댓글 목록
    public List<CommentDto> getComments(int boardId) {
        return commentDao.findByBoardId(boardId);
    }

    // 댓글 삭제 (본인 또는 관리자)
    @Transactional
    public boolean deleteComment(int commentId, int loginMemberId, String role) {
        return commentDao.delete(commentId) > 0;
    }
}
