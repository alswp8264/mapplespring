package com.mapple.service;

import com.mapple.dao.LookbookDao;
import com.mapple.dto.LookbookDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

@Service
public class LookbookServiceImpl implements LookbookService {

    @Autowired
    private LookbookDao lookbookDao;

    @Override
    public void register(LookbookDto dto) {
        lookbookDao.insert(dto);
    }

    @Override
    public List<LookbookDto> getAll() {
        return lookbookDao.findAll();
    }

    @Override
    public List<LookbookDto> getAllWithLike(int memberId) {
        return lookbookDao.findAllWithLike(memberId);
    }

    @Override
    public List<LookbookDto> getMyList(int memberId) {
        return lookbookDao.findByMemberId(memberId);
    }

    @Override
    public void delete(int lookbookId, int memberId) {
        LookbookDto dto = new LookbookDto();
        dto.setLookbookId(lookbookId);
        dto.setMemberId(memberId);
        lookbookDao.deleteByMember(dto);
    }

    @Override
    public void deleteByAdmin(int lookbookId) {
        lookbookDao.deleteById(lookbookId);
    }

    @Override
    public List<Map<String, Object>> getClassStats() {
        return lookbookDao.getClassStats();
    }

    @Override
    public List<Map<String, Object>> getWorldStats() {
        return lookbookDao.getWorldStats();
    }

    @Override
    public int getTotalCount() {
        return lookbookDao.getTotalCount();
    }

    @Override
    public Map<String, Object> toggleLike(int lookbookId, int memberId) {
        Map<String, Object> param = new HashMap<>();
        param.put("lookbookId", lookbookId);
        param.put("memberId",   memberId);

        int already = lookbookDao.isLiked(param);
        if (already > 0) {
            lookbookDao.deleteLike(param);
        } else {
            lookbookDao.insertLike(param);
        }
        lookbookDao.syncLikeCount(lookbookId);
        int count = lookbookDao.getLikeCount(lookbookId);

        Map<String, Object> result = new HashMap<>();
        result.put("liked",     already == 0); // 방금 눌렀으면 true
        result.put("likeCount", count);
        return result;
    }
}
