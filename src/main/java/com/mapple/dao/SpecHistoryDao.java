package com.mapple.dao;

import com.mapple.dto.SpecHistoryDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface SpecHistoryDao {
    // 스펙 저장
    int insert(SpecHistoryDto specHistory);
    // 캐릭터 히스토리 조회
    List<SpecHistoryDto> findByMemberAndChar(SpecHistoryDto specHistory);
}
