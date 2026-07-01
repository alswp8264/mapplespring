package com.mapple.dto;

import java.util.Date;

public class CommentDto {
    private int commentId;
    private int boardId;
    private int memberId;
    private String content;
    private Date regDate;
    // 조회 시 작성자 이름 join
    private String writerName;
    private String loginId;

    public int getCommentId() { return commentId; }
    public void setCommentId(int commentId) { this.commentId = commentId; }

    public int getBoardId() { return boardId; }
    public void setBoardId(int boardId) { this.boardId = boardId; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }

    public String getWriterName() { return writerName; }
    public void setWriterName(String writerName) { this.writerName = writerName; }

    public String getLoginId() { return loginId; }
    public void setLoginId(String loginId) { this.loginId = loginId; }
}
