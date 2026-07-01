package com.mapple.dao;

import com.mapple.dto.AnnouncementDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface AnnouncementDao {
    List<AnnouncementDto> findAll();
    AnnouncementDto findById(int announcementId);
    int insert(AnnouncementDto dto);
    int update(AnnouncementDto dto);
    int delete(int announcementId);
    int increaseView(int announcementId);
    List<AnnouncementDto> findRecent(int limit);
}
