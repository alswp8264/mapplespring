package com.mapple.dao;

import com.mapple.dto.MemberDto;
import org.apache.ibatis.annotations.Mapper;
import java.util.List;

@Mapper
public interface MemberDao {
    // 회원가입
    int insert(MemberDto member);
    // 로그인 (아이디로 조회)
    MemberDto findByLoginId(String loginId);
    // 회원 정보 조회
    MemberDto findById(int memberId);
    // 회원 정보 수정
    int update(MemberDto member);
    // 비밀번호 변경
    int updatePassword(MemberDto member);
    // 회원 탈퇴
    int delete(int memberId);
    // 아이디 중복 확인
    int countByLoginId(String loginId);
    // 전체 회원 목록 (관리자)
    List<MemberDto> findAll();
    // 얼굴 인코딩 저장
    int updateFaceEncoding(MemberDto member);
    // 얼굴 인코딩 삭제
    int deleteFaceEncoding(int memberId);
    // 얼굴 등록된 회원 전체 조회
    List<MemberDto> findAllWithFace();
    // 소셜 로그인 회원 조회
    MemberDto findBySocialId(@org.apache.ibatis.annotations.Param("socialType") String socialType,
                             @org.apache.ibatis.annotations.Param("socialId")   String socialId);
    // 소셜 회원 가입
    int insertSocial(MemberDto member);

    // 아이디 찾기 (이름 + 이메일, 일반 회원만)
    String findLoginIdByNameEmail(@org.apache.ibatis.annotations.Param("name")  String name,
                                  @org.apache.ibatis.annotations.Param("email") String email);
    // 비밀번호 찾기 본인확인 (아이디 + 이름 + 이메일, 일반 회원만)
    MemberDto findForPwReset(@org.apache.ibatis.annotations.Param("loginId") String loginId,
                             @org.apache.ibatis.annotations.Param("name")    String name,
                             @org.apache.ibatis.annotations.Param("email")   String email);
    // 관리자 — 회원 검색 (아이디/이름 LIKE + 권한 필터)
    List<MemberDto> searchMembers(@org.apache.ibatis.annotations.Param("keyword") String keyword,
                                  @org.apache.ibatis.annotations.Param("role")    String role);
    // 회원 밴(글쓰기 제한) 만료시각 설정
    int updateBanUntil(@org.apache.ibatis.annotations.Param("memberId") int memberId,
                       @org.apache.ibatis.annotations.Param("banUntil") java.util.Date banUntil);
    // 벤 해제
    int unban(int memberId);
}
