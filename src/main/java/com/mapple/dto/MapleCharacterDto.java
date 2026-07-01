package com.mapple.dto;

import com.mapple.entity.MapleCharacter;

public class MapleCharacterDto {

    private String charName;
    private int charLevel;
    private String charClass;
    private String guildName;
    private long combatPower;
    private String imageUrl;
    private boolean isMain;

    private MapleCharacterDto() {}

    public String  getCharName()    { return charName; }
    public int     getCharLevel()   { return charLevel; }
    public String  getCharClass()   { return charClass; }
    public String  getGuildName()   { return guildName; }
    public long    getCombatPower() { return combatPower; }
    public String  getImageUrl()    { return imageUrl; }
    public boolean isMain()         { return isMain; }

    public static MapleCharacterDto from(MapleCharacter mc, boolean isMain) {
        MapleCharacterDto dto = new MapleCharacterDto();
        dto.charName    = mc.getCharName();
        dto.charLevel   = mc.getCharLevel() != null ? mc.getCharLevel() : 0;
        dto.charClass   = mc.getCharClass();
        dto.guildName   = mc.getGuildName();
        dto.combatPower = mc.getCombatPower() != null ? mc.getCombatPower() : 0L;
        dto.imageUrl    = mc.getImageUrl();
        dto.isMain      = isMain;
        return dto;
    }
}
