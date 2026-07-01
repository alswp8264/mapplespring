package com.mapple.controller;

import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import com.mapple.dao.MemberDao;
import com.mapple.dto.MemberDto;
import jakarta.servlet.http.HttpSession;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import java.net.URI;
import java.net.URLEncoder;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;

@Controller
@RequestMapping("/member/oauth")
public class OAuthController {

    @Value("${google.client.id}")
    private String googleClientId;

    @Value("${google.client.secret}")
    private String googleClientSecret;

    @Value("${google.redirect.uri}")
    private String googleRedirectUri;

    @Value("${kakao.client.id}")
    private String kakaoClientId;

    @Value("${kakao.client.secret}")
    private String kakaoClientSecret;

    @Value("${kakao.redirect.uri}")
    private String kakaoRedirectUri;

    @Autowired
    private MemberDao memberDao;

    private final ObjectMapper mapper = new ObjectMapper();
    private final HttpClient http = HttpClient.newHttpClient();

    // ── Google ──────────────────────────────────────────────────

    @GetMapping("/google")
    public String googleStart() {
        String url = "https://accounts.google.com/o/oauth2/v2/auth"
                + "?client_id=" + encode(googleClientId)
                + "&redirect_uri=" + encode(googleRedirectUri)
                + "&response_type=code"
                + "&scope=" + encode("email profile");
        return "redirect:" + url;
    }

    @GetMapping("/google/callback")
    public String googleCallback(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "error", required = false) String error,
            HttpSession session) throws Exception {

        if (code == null || error != null) return "redirect:/member/login?msg=google_cancel";

        // 토큰 교환
        String tokenBody = "code=" + encode(code)
                + "&client_id=" + encode(googleClientId)
                + "&client_secret=" + encode(googleClientSecret)
                + "&redirect_uri=" + encode(googleRedirectUri)
                + "&grant_type=authorization_code";
        String tokenJson = post("https://oauth2.googleapis.com/token", tokenBody, null);
        String accessToken = mapper.readTree(tokenJson).path("access_token").asText();

        // 유저 정보 조회
        String userJson = get("https://www.googleapis.com/oauth2/v2/userinfo", accessToken);
        JsonNode user = mapper.readTree(userJson);

        String socialId = user.path("id").asText();
        String name     = user.path("name").asText("Google유저");
        String email    = user.path("email").asText("");

        return processLogin("GOOGLE", socialId, name, email, session);
    }

    // ── Kakao ──────────────────────────────────────────────────

    @GetMapping("/kakao")
    public String kakaoStart() {
        String url = "https://kauth.kakao.com/oauth/authorize"
                + "?client_id=" + encode(kakaoClientId)
                + "&redirect_uri=" + encode(kakaoRedirectUri)
                + "&response_type=code"
                + "&prompt=login";   // 이미 카카오 로그인돼 있어도 매번 로그인 화면 강제 노출
        return "redirect:" + url;
    }

    @GetMapping("/kakao/callback")
    public String kakaoCallback(
            @RequestParam(value = "code", required = false) String code,
            @RequestParam(value = "error", required = false) String error,
            HttpSession session) throws Exception {

        if (code == null || error != null) return "redirect:/member/login?msg=kakao_cancel";

        // 토큰 교환
        String tokenBody = "grant_type=authorization_code"
                + "&client_id=" + encode(kakaoClientId)
                + "&client_secret=" + encode(kakaoClientSecret)
                + "&redirect_uri=" + encode(kakaoRedirectUri)
                + "&code=" + encode(code);
        String tokenJson = post("https://kauth.kakao.com/oauth/token", tokenBody, null);
        System.out.println("[KAKAO TOKEN] " + tokenJson);
        String accessToken = mapper.readTree(tokenJson).path("access_token").asText();

        // 유저 정보 조회
        String userJson = get("https://kapi.kakao.com/v2/user/me", accessToken);
        System.out.println("[KAKAO USER] " + userJson);
        JsonNode user = mapper.readTree(userJson);

        String socialId = user.path("id").asText();
        System.out.println("[KAKAO ID] '" + socialId + "'");
        if (socialId.isEmpty()) return "redirect:/member/login?msg=kakao_fail";
        String nickname = user.path("kakao_account").path("profile").path("nickname").asText("카카오유저");
        String email    = user.path("kakao_account").path("email").asText("");
        if (email.isEmpty()) email = "kakao_" + socialId + "@kakao.social";

        return processLogin("KAKAO", socialId, nickname, email, session);
    }

    // ── 공통: DB 조회/생성 후 세션 저장 ──────────────────────────

    private String processLogin(String type, String socialId, String name, String email, HttpSession session) {
        MemberDto member = memberDao.findBySocialId(type, socialId);
        if (member == null) {
            member = new MemberDto();
            member.setLoginId(type.toLowerCase() + "_" + socialId);
            member.setName(name);
            member.setEmail(email);
            member.setSocialType(type);
            member.setSocialId(socialId);
            memberDao.insertSocial(member);
            member = memberDao.findBySocialId(type, socialId);
        }
        session.setAttribute("loginMember", member);
        return "redirect:/";
    }

    // ── HTTP 헬퍼 ─────────────────────────────────────────────

    private String post(String url, String body, String token) throws Exception {
        HttpRequest.Builder req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Content-Type", "application/x-www-form-urlencoded")
                .POST(HttpRequest.BodyPublishers.ofString(body));
        if (token != null) req.header("Authorization", "Bearer " + token);
        return http.send(req.build(), HttpResponse.BodyHandlers.ofString()).body();
    }

    private String get(String url, String token) throws Exception {
        HttpRequest req = HttpRequest.newBuilder()
                .uri(URI.create(url))
                .header("Authorization", "Bearer " + token)
                .GET().build();
        return http.send(req, HttpResponse.BodyHandlers.ofString()).body();
    }

    private String encode(String s) {
        return URLEncoder.encode(s == null ? "" : s, StandardCharsets.UTF_8);
    }
}
