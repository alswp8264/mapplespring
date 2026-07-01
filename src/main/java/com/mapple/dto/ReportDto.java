package com.mapple.dto;

import java.util.Date;

public class ReportDto {
    private int reportId;
    private int boardId;
    private int reporterId;
    private String reason;
    private String status;
    private Date regDate;
    // 조회 시 조인
    private String boardTitle;
    private int authorId;
    private String authorName;
    private String reporterName;

    public int getReportId() { return reportId; }
    public void setReportId(int reportId) { this.reportId = reportId; }
    public int getBoardId() { return boardId; }
    public void setBoardId(int boardId) { this.boardId = boardId; }
    public int getReporterId() { return reporterId; }
    public void setReporterId(int reporterId) { this.reporterId = reporterId; }
    public String getReason() { return reason; }
    public void setReason(String reason) { this.reason = reason; }
    public String getStatus() { return status; }
    public void setStatus(String status) { this.status = status; }
    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }
    public String getBoardTitle() { return boardTitle; }
    public void setBoardTitle(String boardTitle) { this.boardTitle = boardTitle; }
    public int getAuthorId() { return authorId; }
    public void setAuthorId(int authorId) { this.authorId = authorId; }
    public String getAuthorName() { return authorName; }
    public void setAuthorName(String authorName) { this.authorName = authorName; }
    public String getReporterName() { return reporterName; }
    public void setReporterName(String reporterName) { this.reporterName = reporterName; }
}
