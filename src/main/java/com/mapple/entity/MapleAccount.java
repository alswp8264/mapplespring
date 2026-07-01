package com.mapple.entity;

import jakarta.persistence.*;

import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@Entity
@Table(name = "MAPLE_ACCOUNT")
public class MapleAccount {

    @Id
    @GeneratedValue(strategy = GenerationType.SEQUENCE, generator = "maple_account_seq")
    @SequenceGenerator(name = "maple_account_seq", sequenceName = "MAPLE_ACCOUNT_SEQ", allocationSize = 1)
    private Long id;

    @Column(name = "REP_CHAR_NAME", nullable = false, length = 50)
    private String repCharName;

    @Column(name = "OCID", nullable = false, length = 100)
    private String ocid;

    @Column(name = "UNION_LEVEL")
    private Integer unionLevel;

    @Column(name = "LAST_UPDATED_AT")
    private LocalDateTime lastUpdatedAt;

    @OneToMany(mappedBy = "mapleAccount",
               cascade = CascadeType.ALL,
               orphanRemoval = true,
               fetch = FetchType.LAZY)
    private List<MapleCharacter> characters = new ArrayList<>();

    public MapleAccount() {}

    public Long getId() { return id; }
    public void setId(Long id) { this.id = id; }

    public String getRepCharName() { return repCharName; }
    public void setRepCharName(String repCharName) { this.repCharName = repCharName; }

    public String getOcid() { return ocid; }
    public void setOcid(String ocid) { this.ocid = ocid; }

    public Integer getUnionLevel() { return unionLevel; }
    public void setUnionLevel(Integer unionLevel) { this.unionLevel = unionLevel; }

    public LocalDateTime getLastUpdatedAt() { return lastUpdatedAt; }
    public void setLastUpdatedAt(LocalDateTime lastUpdatedAt) { this.lastUpdatedAt = lastUpdatedAt; }

    public List<MapleCharacter> getCharacters() { return characters; }
    public void setCharacters(List<MapleCharacter> characters) { this.characters = characters; }

    public void addCharacter(MapleCharacter mc) {
        mc.setMapleAccount(this);
        this.characters.add(mc);
    }
}
