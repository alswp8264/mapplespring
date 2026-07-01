package com.mapple.dao;

import com.mapple.dto.ReportDto;
import org.apache.ibatis.annotations.Mapper;
import org.apache.ibatis.annotations.Param;
import java.util.List;

@Mapper
public interface ReportDao {
    int insert(ReportDto report);
    List<ReportDto> findPending();
    ReportDto findById(int reportId);
    int updateStatus(@Param("reportId") int reportId, @Param("status") String status);
    // 같은 사람이 같은 글을 중복 신고했는지 (PENDING 기준)
    int countDup(@Param("boardId") int boardId, @Param("reporterId") int reporterId);
    int countPending();
}
