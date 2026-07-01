package com.mapple.dto;

import java.util.Date;

public class LookbookDto {
    private int    lookbookId;
    private int    memberId;
    private String charName;
    private String charImage;
    private String charClass;
    private String charWorld;
    private int    charLevel;
    private String title;
    private String writerName;   // JOIN
    private Date   regDate;
    private int    likeCount;
    private int    likedByMe;   // 1=좋아요 누름, 0=아님

    public int    getLookbookId()            { return lookbookId; }
    public void   setLookbookId(int id)      { this.lookbookId = id; }

    public int    getMemberId()              { return memberId; }
    public void   setMemberId(int id)        { this.memberId = id; }

    public String getCharName()              { return charName; }
    public void   setCharName(String v)      { this.charName = v; }

    public String getCharImage()             { return charImage; }
    public void   setCharImage(String v)     { this.charImage = v; }

    public String getCharClass()             { return charClass; }
    public void   setCharClass(String v)     { this.charClass = v; }

    public String getCharWorld()             { return charWorld; }
    public void   setCharWorld(String v)     { this.charWorld = v; }

    public int    getCharLevel()             { return charLevel; }
    public void   setCharLevel(int v)        { this.charLevel = v; }

    public String getTitle()                 { return title; }
    public void   setTitle(String v)         { this.title = v; }

    public String getWriterName()            { return writerName; }
    public void   setWriterName(String v)    { this.writerName = v; }

    public Date   getRegDate()               { return regDate; }
    public void   setRegDate(Date v)         { this.regDate = v; }

    public int    getLikeCount()             { return likeCount; }
    public void   setLikeCount(int v)        { this.likeCount = v; }

    public int    getLikedByMe()             { return likedByMe; }
    public void   setLikedByMe(int v)        { this.likedByMe = v; }
}
