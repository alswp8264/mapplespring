package com.mapple.dto;

public class NoticeThumbDto {
    private String noticeId;
    private String noticeType;  // "event" or "cashshop"
    private String thumbnail;

    public String getNoticeId()   { return noticeId; }
    public String getNoticeType() { return noticeType; }
    public String getThumbnail()  { return thumbnail; }

    public void setNoticeId(String noticeId)     { this.noticeId = noticeId; }
    public void setNoticeType(String noticeType) { this.noticeType = noticeType; }
    public void setThumbnail(String thumbnail)   { this.thumbnail = thumbnail; }
}
