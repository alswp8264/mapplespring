package com.mapple.dto;

import java.util.Date;

public class MemberDto {
    private int memberId;
    private String loginId;
    private String password;
    private String name;
    private String email;
    private String role;
    private Date regDate;
    private String faceEncoding;
    private String socialType;
    private String socialId;
    private Date banUntil;   // 이 시각 전까지 글/댓글 작성 제한

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }

    public String getPassword() { return password; }
    public void setPassword(String password) { this.password = password; }

    public String getName() { return name; }
    public void setName(String name) { this.name = name; }

    public String getEmail() { return email; }
    public void setEmail(String email) { this.email = email; }

    public String getRole() { return role; }
    public void setRole(String role) { this.role = role; }

    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }

    public String getFaceEncoding() { return faceEncoding; }
    public void setFaceEncoding(String faceEncoding) { this.faceEncoding = faceEncoding; }

    public String getSocialType() { return socialType; }
    public void setSocialType(String socialType) { this.socialType = socialType; }

    public String getSocialId() { return socialId; }
    public void setSocialId(String socialId) { this.socialId = socialId; }

    public Date getBanUntil() { return banUntil; }
    public void setBanUntil(Date banUntil) { this.banUntil = banUntil; }
}
