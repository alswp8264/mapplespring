package com.mapple.service;

import com.mapple.dao.FavoriteDao;
import com.mapple.dao.SpecHistoryDao;
import com.mapple.dto.FavoriteDto;
import com.mapple.dto.SpecHistoryDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class FavoriteService {

    @Autowired
    private FavoriteDao favoriteDao;

    @Autowired
    private SpecHistoryDao specHistoryDao;

    // 즐겨찾기 추가
    @Transactional
    public boolean add(FavoriteDto favorite) {
        if (favoriteDao.countByMemberAndChar(favorite) > 0) {
            return false; // 이미 등록됨
        }
        return favoriteDao.insert(favorite) > 0;
    }

    // 즐겨찾기 목록
    public List<FavoriteDto> getList(int memberId) {
        return favoriteDao.findByMemberId(memberId);
    }

    // 즐겨찾기 삭제
    @Transactional
    public boolean delete(int favId) {
        return favoriteDao.delete(favId) > 0;
    }

    // 스펙 히스토리 저장
    @Transactional
    public boolean saveSpec(SpecHistoryDto spec) {
        return specHistoryDao.insert(spec) > 0;
    }

    // 스펙 히스토리 조회
    public List<SpecHistoryDto> getSpecHistory(int memberId, String charName) {
        SpecHistoryDto param = new SpecHistoryDto();
        param.setMemberId(memberId);
        param.setCharName(charName);
        return specHistoryDao.findByMemberAndChar(param);
    }
}
