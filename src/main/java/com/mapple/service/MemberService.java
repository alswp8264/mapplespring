package com.mapple.service;

import com.mapple.dao.MemberDao;
import com.mapple.dto.MemberDto;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import java.util.List;

@Service
public class MemberService {

    @Autowired
    private MemberDao memberDao;

    // 회원가입
    @Transactional
    public boolean join(MemberDto member) {
        if (memberDao.countByLoginId(member.getLoginId()) > 0) {
            return false; // 아이디 중복
        }
        return memberDao.insert(member) > 0;
    }

    // 로그인
    public MemberDto login(String loginId, String password) {
        MemberDto member = memberDao.findByLoginId(loginId);
        if (member != null && member.getPassword().equals(password)) {
            return member;
        }
        return null;
    }

    // 아이디 중복 확인
    public boolean isLoginIdDuplicate(String loginId) {
        return memberDao.countByLoginId(loginId) > 0;
    }

    // 회원 정보 조회
    public MemberDto findById(int memberId) {
        return memberDao.findById(memberId);
    }

    // 회원 정보 수정
    @Transactional
    public boolean update(MemberDto member) {
        return memberDao.update(member) > 0;
    }

    // 비밀번호 변경
    @Transactional
    public boolean updatePassword(int memberId, String currentPw, String newPw) {
        MemberDto member = memberDao.findById(memberId);
        if (member == null || !member.getPassword().equals(currentPw)) {
            return false;
        }
        member.setPassword(newPw);
        return memberDao.updatePassword(member) > 0;
    }

    // 회원 탈퇴
    @Transactional
    public boolean delete(int memberId, String password) {
        MemberDto member = memberDao.findById(memberId);
        if (member == null || !member.getPassword().equals(password)) {
            return false;
        }
        return memberDao.delete(memberId) > 0;
    }

    // 전체 회원 목록 (관리자)
    public List<MemberDto> findAll() {
        return memberDao.findAll();
    }

    // 얼굴 인코딩 저장
    @Transactional
    public boolean registerFace(int memberId, String encoding) {
        MemberDto member = new MemberDto();
        member.setMemberId(memberId);
        member.setFaceEncoding(encoding);
        return memberDao.updateFaceEncoding(member) > 0;
    }

    // 얼굴 인코딩 삭제
    @Transactional
    public boolean deleteFace(int memberId) {
        return memberDao.deleteFaceEncoding(memberId) > 0;
    }

    // 얼굴 등록된 회원 전체 조회
    public List<MemberDto> findAllWithFace() {
        return memberDao.findAllWithFace();
    }

    // ── 아이디 / 비밀번호 찾기 ──────────────────────────────
    // 아이디 찾기 (이름 + 이메일)
    public String findLoginId(String name, String email) {
        return memberDao.findLoginIdByNameEmail(name, email);
    }

    // 비밀번호 찾기 본인확인 → 일치 시 회원 반환(null이면 불일치)
    public MemberDto verifyForPwReset(String loginId, String name, String email) {
        return memberDao.findForPwReset(loginId, name, email);
    }

    // 본인확인된 회원의 비밀번호 재설정
    @Transactional
    public boolean resetPassword(int memberId, String newPw) {
        MemberDto member = new MemberDto();
        member.setMemberId(memberId);
        member.setPassword(newPw);
        return memberDao.updatePassword(member) > 0;
    }

    // ── 관리자 ─────────────────────────────────────────────
    // 회원 검색 (아이디/이름 + 권한)
    public List<MemberDto> searchMembers(String keyword, String role) {
        return memberDao.searchMembers(keyword, role);
    }

    // 관리자 회원 강제 삭제 (비번 확인 없이)
    @Transactional
    public boolean deleteByAdmin(int memberId) {
        return memberDao.delete(memberId) > 0;
    }

    // ── 글쓰기 제한(밴) ─────────────────────────────────────
    // 지정 시간(시간 단위) 동안 글쓰기 금지
    @Transactional
    public void ban(int memberId, int hours) {
        long until = System.currentTimeMillis() + hours * 3600_000L;
        memberDao.updateBanUntil(memberId, new java.util.Date(until));
    }

    // 현재 밴 상태인지 (DB 최신값 기준)
    public boolean isBanned(int memberId) {
        java.util.Date until = getBanUntil(memberId);
        return until != null && until.after(new java.util.Date());
    }

    public java.util.Date getBanUntil(int memberId) {
        MemberDto m = memberDao.findById(memberId);
        return m == null ? null : m.getBanUntil();
    }

    @Transactional
    public void unban(int memberId) { memberDao.unban(memberId); }
}
