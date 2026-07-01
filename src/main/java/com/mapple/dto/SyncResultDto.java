package com.mapple.dto;

import java.time.LocalDateTime;
import java.util.List;

public class SyncResultDto {

    private String message;
    private LocalDateTime syncedAt;
    private List<MapleCharacterDto> characters;

    public SyncResultDto(String message, LocalDateTime syncedAt, List<MapleCharacterDto> characters) {
        this.message    = message;
        this.syncedAt   = syncedAt;
        this.characters = characters;
    }

    public String getMessage()                     { return message; }
    public LocalDateTime getSyncedAt()             { return syncedAt; }
    public List<MapleCharacterDto> getCharacters() { return characters; }
}
