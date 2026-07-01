package com.mapple.dao;

import com.mapple.dto.InquiryDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface InquiryDao {
    void insert(InquiryDto dto);
    List<InquiryDto> findByMemberId(int memberId);
    List<InquiryDto> findAll();
    InquiryDto findById(int inquiryId);
    void answer(InquiryDto dto);
}
