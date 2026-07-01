package com.mapple.dto;

import java.util.Date;

public class InquiryDto {
    private int inquiryId;
    private int memberId;
    private String loginId;
    private String memberName;
    private String title;
    private String content;
    private String answer;
    private String status;
    private Date createdAt;
    private Date answeredAt;

    public int getInquiryId()        { return inquiryId; }
    public void setInquiryId(int v)  { this.inquiryId = v; }
    public int getMemberId()         { return memberId; }
    public void setMemberId(int v)   { this.memberId = v; }
    public String getLoginId()       { return loginId; }
    public void setLoginId(String v) { this.loginId = v; }
    public String getMemberName()    { return memberName; }
    public void setMemberName(String v) { this.memberName = v; }
    public String getTitle()         { return title; }
    public void setTitle(String v)   { this.title = v; }
    public String getContent()       { return content; }
    public void setContent(String v) { this.content = v; }
    public String getAnswer()        { return answer; }
    public void setAnswer(String v)  { this.answer = v; }
    public String getStatus()        { return status; }
    public void setStatus(String v)  { this.status = v; }
    public Date getCreatedAt()       { return createdAt; }
    public void setCreatedAt(Date v) { this.createdAt = v; }
    public Date getAnsweredAt()      { return answeredAt; }
    public void setAnsweredAt(Date v){ this.answeredAt = v; }
}
