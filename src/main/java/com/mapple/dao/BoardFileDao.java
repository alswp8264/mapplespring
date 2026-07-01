package com.mapple.dao;

import com.mapple.dto.BoardFileDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface BoardFileDao {
    int insert(BoardFileDto file);
    List<BoardFileDto> findByBoardId(int boardId);
}
