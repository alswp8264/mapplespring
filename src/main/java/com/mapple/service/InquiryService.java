package com.mapple.service;

import com.mapple.dao.InquiryDao;
import com.mapple.dto.InquiryDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import java.util.List;

@Service
public class InquiryService {
    @Autowired InquiryDao inquiryDao;

    public void write(InquiryDto dto)           { inquiryDao.insert(dto); }
    public List<InquiryDto> getMyList(int id)   { return inquiryDao.findByMemberId(id); }
    public List<InquiryDto> getAll()            { return inquiryDao.findAll(); }
    public InquiryDto getById(int id)           { return inquiryDao.findById(id); }
    public void answer(InquiryDto dto)          { inquiryDao.answer(dto); }
}
