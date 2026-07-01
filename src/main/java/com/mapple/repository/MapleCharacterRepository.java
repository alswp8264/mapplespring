package com.mapple.repository;

import com.mapple.entity.MapleAccount;
import com.mapple.entity.MapleCharacter;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.query.Param;

import java.util.List;
import java.util.Optional;

public interface MapleCharacterRepository extends JpaRepository<MapleCharacter, Long> {

    Optional<MapleCharacter> findByCharName(String charName);

    /** 레벨 내림차순 정렬 (0번 = 본캐) */
    List<MapleCharacter> findByMapleAccountOrderByCharLevelDesc(MapleAccount account);

    /** 계정 소속 캐릭터 전체 삭제 (재등록 전 초기화) */
    @Query("DELETE FROM MapleCharacter mc WHERE mc.mapleAccount = :account")
    @org.springframework.data.jpa.repository.Modifying
    void deleteAllByMapleAccount(@Param("account") MapleAccount account);
}
