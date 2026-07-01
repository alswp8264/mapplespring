package com.mapple.dao;

import com.mapple.dto.BoardDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface BoardDao {
    // 게시글 작성
    int insert(BoardDto board);
    // 게시글 목록 (페이지네이션 + 카테고리 필터)
    List<BoardDto> findAll(Map<String, Object> params);
    // 전체 게시글 수 (카테고리 필터)
    int count(@org.apache.ibatis.annotations.Param("category") String category);
    // 게시글 상세 조회
    BoardDto findById(int boardId);
    // 조회수 증가
    int updateViewCnt(int boardId);
    // 게시글 수정
    int update(BoardDto board);
    // 게시글 삭제
    int delete(int boardId);
}
