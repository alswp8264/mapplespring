package com.mapple.dao;

import com.mapple.dto.LookbookDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;
import java.util.Map;

@Mapper
public interface LookbookDao {
    int insert(LookbookDto dto);
    List<LookbookDto> findAll();
    List<LookbookDto> findAllWithLike(int memberId);
    List<LookbookDto> findByMemberId(int memberId);
    int deleteByMember(LookbookDto dto);
    int deleteById(int lookbookId);   // 관리자 강제 삭제
    List<Map<String, Object>> getClassStats();
    List<Map<String, Object>> getWorldStats();
    int getTotalCount();
    // 좋아요
    int insertLike(Map<String, Object> param);
    int deleteLike(Map<String, Object> param);
    int isLiked(Map<String, Object> param);
    int getLikeCount(int lookbookId);
    void syncLikeCount(int lookbookId);
}
