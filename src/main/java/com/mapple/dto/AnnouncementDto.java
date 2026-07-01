package com.mapple.dto;

import java.util.Date;

public class AnnouncementDto {
    private int announcementId;
    private int memberId;
    private String writerName;   // member_tb 조인
    private String title;
    private String content;
    private int viewCnt;
    private Date regDate;

    public int getAnnouncementId() { return announcementId; }
    public void setAnnouncementId(int announcementId) { this.announcementId = announcementId; }
    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }
    public String getWriterName() { return writerName; }
    public void setWriterName(String writerName) { this.writerName = writerName; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }
    public int getViewCnt() { return viewCnt; }
    public void setViewCnt(int viewCnt) { this.viewCnt = viewCnt; }
    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }
}
