package com.mapple.service;

import com.mapple.dao.BoardDao;
import com.mapple.dao.MemberDao;
import com.mapple.dao.ReportDao;
import com.mapple.dto.ReportDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class ReportService {

    private static final int BAN_HOURS = 1;   // 신고 승인 시 작성자 1시간 밴

    @Autowired private ReportDao reportDao;
    @Autowired private BoardDao boardDao;
    @Autowired private MemberDao memberDao;

    // 신고 접수 (중복 신고 방지)
    @Transactional
    public boolean report(int boardId, int reporterId, String reason) {
        if (reportDao.countDup(boardId, reporterId) > 0) return false;
        ReportDto r = new ReportDto();
        r.setBoardId(boardId);
        r.setReporterId(reporterId);
        r.setReason(reason);
        return reportDao.insert(r) > 0;
    }

    // 관리자 — 대기 중 신고 목록
    public List<ReportDto> getPending() {
        return reportDao.findPending();
    }

    public int getPendingCount() {
        return reportDao.countPending();
    }

    // 관리자 승인 → 작성자 1시간 밴 + 게시글 삭제(연관 신고/파일 cascade)
    @Transactional
    public boolean approve(int reportId) {
        ReportDto r = reportDao.findById(reportId);
        if (r == null) return false;
        long until = System.currentTimeMillis() + BAN_HOURS * 3600_000L;
        memberDao.updateBanUntil(r.getAuthorId(), new java.util.Date(until));  // 작성자 밴
        boardDao.delete(r.getBoardId());  // 게시글 삭제 → report_tb FK cascade 로 신고도 제거
        return true;
    }

    // 관리자 반려 (게시글 유지, 신고만 처리됨 표시)
    @Transactional
    public boolean reject(int reportId) {
        return reportDao.updateStatus(reportId, "DONE") > 0;
    }
}
