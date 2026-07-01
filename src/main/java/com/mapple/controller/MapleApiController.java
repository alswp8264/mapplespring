package com.mapple.controller;

import com.mapple.dto.MapleCharacterDto;
import com.mapple.dto.SyncResultDto;
import com.mapple.exception.CharacterNotFoundException;
import com.mapple.exception.CooldownException;
import com.mapple.service.MapleAccountService;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

/**
 * 본캐/부캐 조회 및 수동 갱신 REST API
 *
 * GET  /api/maple/alts?charName=버터    → DB 캐시 우선 반환 (없으면 Nexon API 최초 등록)
 * POST /api/maple/sync?charName=버터    → 수동 갱신 (10분 쿨타임)
 */
@RestController
@RequestMapping("/api/maple")
public class MapleApiController {

    @Autowired
    private MapleAccountService mapleAccountService;

    // ─────────────────────────────────────────────────────────────
    // 1. 본캐/부캐 목록 조회
    // ─────────────────────────────────────────────────────────────
    @GetMapping("/alts")
    public ResponseEntity<?> getAlts(@RequestParam("charName") String charName) {
        if (charName == null || charName.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(error("charName 파라미터가 필요합니다."));
        }
        try {
            List<MapleCharacterDto> result = mapleAccountService.getAlts(charName.trim());
            return ResponseEntity.ok(result);
        } catch (CharacterNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(error("조회 중 오류가 발생했습니다: " + e.getMessage()));
        }
    }

    // ─────────────────────────────────────────────────────────────
    // 2. 수동 갱신 (쿨타임 10분)
    // ─────────────────────────────────────────────────────────────
    @PostMapping("/sync")
    public ResponseEntity<?> sync(@RequestParam("charName") String charName) {
        if (charName == null || charName.isBlank()) {
            return ResponseEntity.badRequest()
                    .body(error("charName 파라미터가 필요합니다."));
        }
        try {
            SyncResultDto result = mapleAccountService.sync(charName.trim());
            return ResponseEntity.ok(result);
        } catch (CooldownException e) {
            // 쿨타임 중 — 429 Too Many Requests
            return ResponseEntity.status(HttpStatus.TOO_MANY_REQUESTS).body(error(e.getMessage()));
        } catch (CharacterNotFoundException e) {
            return ResponseEntity.status(HttpStatus.NOT_FOUND).body(error(e.getMessage()));
        } catch (Exception e) {
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body(error("갱신 중 오류가 발생했습니다: " + e.getMessage()));
        }
    }

    private Map<String, String> error(String message) {
        return Map.of("error", message);
    }
}
