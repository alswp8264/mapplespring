package com.mapple.dao;

import com.mapple.dto.CommentDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface CommentDao {
    // 댓글 작성
    int insert(CommentDto comment);
    // 게시글의 댓글 목록
    List<CommentDto> findByBoardId(int boardId);
    // 댓글 삭제
    int delete(int commentId);
}
