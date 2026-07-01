package com.mapple.dao;

import com.mapple.dto.FavoriteDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface FavoriteDao {
    // 즐겨찾기 추가
    int insert(FavoriteDto favorite);
    // 회원의 즐겨찾기 목록
    List<FavoriteDto> findByMemberId(int memberId);
    // 즐겨찾기 삭제
    int delete(int favId);
    // 중복 확인
    int countByMemberAndChar(FavoriteDto favorite);
}
