package com.mapple.dto;

import java.util.Date;

public class SpecHistoryDto {
    private int historyId;
    private int memberId;
    private String charName;
    private int attackPower;
    private int bossDmg;
    private int ignDef;
    private int finalDmg;
    private Date saveDate;

    public int getHistoryId() { return historyId; }
    public void setHistoryId(int historyId) { this.historyId = historyId; }

    public int getMemberId() { return memberId; }
    public void setMemberId(int memberId) { this.memberId = memberId; }

    public String getCharName() { return charName; }
    public void setCharName(String charName) { this.charName = charName; }

    public int getAttackPower() { return attackPower; }
    public void setAttackPower(int attackPower) { this.attackPower = attackPower; }

    public int getBossDmg() { return bossDmg; }
    public void setBossDmg(int bossDmg) { this.bossDmg = bossDmg; }

    public int getIgnDef() { return ignDef; }
    public void setIgnDef(int ignDef) { this.ignDef = ignDef; }

    public int getFinalDmg() { return finalDmg; }
    public void setFinalDmg(int finalDmg) { this.finalDmg = finalDmg; }

    public Date getSaveDate() { return saveDate; }
    public void setSaveDate(Date saveDate) { this.saveDate = saveDate; }
}
