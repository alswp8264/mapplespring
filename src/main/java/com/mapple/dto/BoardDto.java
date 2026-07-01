package com.mapple.dto;

import java.util.Date;

public class BoardDto {
    private int boardId;
    private int memberId;
    private String title;
    private String content;
    private int viewCnt;
    private Date regDate;
    private Date modDate;
    private String category;   // 공략/전사/도적/마법사/해적/궁수
    // 조회 시 회원 이름 join
    private String writerName;
    private String loginId;

    public int getBoardId() { return boardId; }
    public void setBoardId(int boardId) { this.boardId = boardId; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public int getViewCnt() { return viewCnt; }
    public void setViewCnt(int viewCnt) { this.viewCnt = viewCnt; }

    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }

    public Date getModDate() { return modDate; }
    public void setModDate(Date modDate) { this.modDate = modDate; }

    public String getWriterName() { return writerName; }
    public void setWriterName(String writerName) { this.writerName = writerName; }

    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }

    public String getCategory() { return category; }
    public void setCategory(String category) { this.category = category; }
}
