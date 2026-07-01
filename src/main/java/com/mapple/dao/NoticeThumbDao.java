package com.mapple.dao;

import com.mapple.dto.NoticeThumbDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;

@Mapper
public interface NoticeThumbDao {
    String findThumbnail(@Param("noticeId") String noticeId,
                         @Param("noticeType") String noticeType);
    void insert(NoticeThumbDto dto);
}
