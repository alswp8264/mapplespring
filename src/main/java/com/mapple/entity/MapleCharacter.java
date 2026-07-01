package com.mapple.entity;

import jakarta.persistence.*;

@Entity
@Table(name = "MAPLE_CHARACTER",
       indexes = @Index(name = "idx_maple_char_name", columnList = "CHAR_NAME"))
public class MapleCharacter {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "maple_char_seq")
    @SequenceGenerator(name = "maple_char_seq", sequenceName = "MAPLE_CHAR_SEQ", allocationSize = 1)
    private Long id;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "MAPLE_ACCOUNT_ID", nullable = false)
    private MapleAccount mapleAccount;

    @Column(name = "CHAR_NAME", length = 50)
    private String charName;

    @Column(name = "CHAR_OCID", length = 100)
    private String charOcid;

    @Column(name = "CHAR_LEVEL")
    private Integer charLevel;

    @Column(name = "CHAR_CLASS", length = 50)
    private String charClass;

    @Column(name = "GUILD_NAME", length = 50)
    private String guildName;

    @Column(name = "COMBAT_POWER")
    private Long combatPower;

    @Column(name = "IMAGE_URL", length = 2000)
    private String imageUrl;

    @Column(name = "IS_VALID", nullable = false)
    private boolean isValid = true;

    public MapleCharacter() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public MapleAccount getMapleAccount() { return mapleAccount; }
    public void setMapleAccount(MapleAccount mapleAccount) { this.mapleAccount = mapleAccount; }

    public String getCharName() { return charName; }
    public void setCharName(String charName) { this.charName = charName; }

    public String getCharOcid() { return charOcid; }
    public void setCharOcid(String charOcid) { this.charOcid = charOcid; }

    public Integer getCharLevel() { return charLevel; }
    public void setCharLevel(Integer charLevel) { this.charLevel = charLevel; }

    public String getCharClass() { return charClass; }
    public void setCharClass(String charClass) { this.charClass = charClass; }

    public String getGuildName() { return guildName; }
    public void setGuildName(String guildName) { this.guildName = guildName; }

    public Long getCombatPower() { return combatPower; }
    public void setCombatPower(Long combatPower) { this.combatPower = combatPower; }

    public String getImageUrl() { return imageUrl; }
    public void setImageUrl(String imageUrl) { this.imageUrl = imageUrl; }

    public boolean isValid() { return isValid; }
    public void setValid(boolean isValid) { this.isValid = isValid; }
}
