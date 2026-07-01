package com.mapple.service;

import com.mapple.dto.LookbookDto;
import java.util.List;
import java.util.Map;

public interface LookbookService {
    void register(LookbookDto dto);
    List<LookbookDto> getAll();
    List<LookbookDto> getAllWithLike(int memberId);
    List<LookbookDto> getMyList(int memberId);
    void delete(int lookbookId, int memberId);
    void deleteByAdmin(int lookbookId);   // 관리자 강제 삭제
    List<Map<String, Object>> getClassStats();
    List<Map<String, Object>> getWorldStats();
    int getTotalCount();
    // 좋아요 토글 → 변경 후 좋아요 수 반환
    Map<String, Object> toggleLike(int lookbookId, int memberId);
}
