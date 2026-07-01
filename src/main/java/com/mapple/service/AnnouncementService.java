package com.mapple.service;

import com.mapple.dao.AnnouncementDao;
import com.mapple.dto.AnnouncementDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class AnnouncementService {

    @Autowired
    private AnnouncementDao announcementDao;

    public List<AnnouncementDto> getList() {
        return announcementDao.findAll();
    }

    public List<AnnouncementDto> getRecent(int limit) {
        return announcementDao.findRecent(limit);
    }

    public AnnouncementDto findById(int id) {
        return announcementDao.findById(id);
    }

    // 상세 조회(조회수 증가)
    @Transactional
    public AnnouncementDto getDetail(int id) {
        announcementDao.increaseView(id);
        return announcementDao.findById(id);
    }

    @Transactional
    public boolean write(AnnouncementDto dto) {
        return announcementDao.insert(dto) > 0;
    }

    @Transactional
    public boolean update(AnnouncementDto dto) {
        return announcementDao.update(dto) > 0;
    }

    @Transactional
    public boolean delete(int id) {
        return announcementDao.delete(id) > 0;
    }
}
