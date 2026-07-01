package com.mapple.dto;

import java.util.Date;

public class FavoriteDto {
    private int favId;
    private int memberId;
    private String charName;
    private Date regDate;

    public int getFavId() { return favId; }
    public void setFavId(int favId) { this.favId = favId; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public String getCharName() { return charName; }
    public void setCharName(String charName) { this.charName = charName; }

    public Date getRegDate() { return regDate; }
    public void setRegDate(Date regDate) { this.regDate = regDate; }
}
