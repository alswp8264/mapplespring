package com.mapple.repository;

import com.mapple.entity.MapleAccount;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.Optional;

public interface MapleAccountRepository extends JpaRepository<MapleAccount, Long> {

    Optional<MapleAccount> findByOcid(String ocid);

    Optional<MapleAccount> findByRepCharName(String repCharName);
}
