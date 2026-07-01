package com.mapple.dto;

public class BoardFileDto {
    private int fileId;
    private int boardId;
    private String fileName;   // 서버 저장 파일명(UUID)
    private String origName;   // 원본 파일명
    private String fileType;   // 'image' 또는 'video'

    public int getFileId() { return fileId; }
    public void setFileId(int fileId) { this.fileId = fileId; }
    public int getBoardId() { return boardId; }
    public void setBoardId(int boardId) { this.boardId = boardId; }
    public String getFileName() { return fileName; }
    public void setFileName(String fileName) { this.fileName = fileName; }
    public String getOrigName() { return origName; }
    public void setOrigName(String origName) { this.origName = origName; }
    public String getFileType() { return fileType; }
    public void setFileType(String fileType) { this.fileType = fileType; }
}
