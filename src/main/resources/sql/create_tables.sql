-- =============================================
-- Mapple 프로젝트 테이블 생성 스크립트
-- Oracle DB / HR 계정
-- =============================================

-- 기존 테이블 삭제 (순서 중요 - FK 때문에 역순)
DROP TABLE comment_tb CASCADE CONSTRAINTS;
DROP TABLE board_tb CASCADE CONSTRAINTS;
DROP TABLE spec_history_tb CASCADE CONSTRAINTS;
DROP TABLE favorite_tb CASCADE CONSTRAINTS;
DROP TABLE member_tb CASCADE CONSTRAINTS;

-- 기존 시퀀스 삭제
DROP SEQUENCE member_seq;
DROP SEQUENCE board_seq;
DROP SEQUENCE comment_seq;
DROP SEQUENCE favorite_seq;
DROP SEQUENCE spec_history_seq;

-- =============================================
-- 1. 회원 테이블
-- =============================================
CREATE TABLE member_tb (
    member_id   NUMBER          NOT NULL,
    login_id    VARCHAR2(50)    NOT NULL,
    password    VARCHAR2(200)   NOT NULL,
    name        VARCHAR2(50)    NOT NULL,
    email       VARCHAR2(100)   NOT NULL,
    role        VARCHAR2(10)    DEFAULT 'USER' NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_member PRIMARY KEY (member_id),
    CONSTRAINT uq_member_login_id UNIQUE (login_id),
    CONSTRAINT ck_member_role CHECK (role IN ('USER', 'ADMIN'))
);

CREATE SEQUENCE member_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- 관리자 계정 기본 삽입
INSERT INTO member_tb (member_id, login_id, password, name, email, role)
VALUES (member_seq.NEXTVAL, 'admin', 'admin1234', '관리자', 'admin@mapple.com', 'ADMIN');

COMMIT;

-- =============================================
-- 2. 즐겨찾기 테이블
-- =============================================
CREATE TABLE favorite_tb (
    fav_id      NUMBER          NOT NULL,
    member_id   NUMBER          NOT NULL,
    char_name   VARCHAR2(100)   NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_favorite PRIMARY KEY (fav_id),
    CONSTRAINT fk_favorite_member FOREIGN KEY (member_id) REFERENCES member_tb(member_id) ON DELETE CASCADE,
    CONSTRAINT uq_favorite UNIQUE (member_id, char_name)
);

CREATE SEQUENCE favorite_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =============================================
-- 3. 스펙 히스토리 테이블
-- =============================================
CREATE TABLE spec_history_tb (
    history_id      NUMBER          NOT NULL,
    member_id       NUMBER          NOT NULL,
    char_name       VARCHAR2(100)   NOT NULL,
    attack_power    NUMBER,
    boss_dmg        NUMBER,
    ign_def         NUMBER,
    final_dmg       NUMBER,
    save_date       DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_spec_history PRIMARY KEY (history_id),
    CONSTRAINT fk_spec_member FOREIGN KEY (member_id) REFERENCES member_tb(member_id) ON DELETE CASCADE
);

CREATE SEQUENCE spec_history_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =============================================
-- 4. 게시판 테이블
-- =============================================
CREATE TABLE board_tb (
    board_id    NUMBER          NOT NULL,
    member_id   NUMBER          NOT NULL,
    title       VARCHAR2(200)   NOT NULL,
    content     CLOB            NOT NULL,
    view_cnt    NUMBER          DEFAULT 0 NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    mod_date    DATE,
    CONSTRAINT pk_board PRIMARY KEY (board_id),
    CONSTRAINT fk_board_member FOREIGN KEY (member_id) REFERENCES member_tb(member_id) ON DELETE CASCADE
);

CREATE SEQUENCE board_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =============================================
-- 5. 댓글 테이블
-- =============================================
CREATE TABLE comment_tb (
    comment_id  NUMBER          NOT NULL,
    board_id    NUMBER          NOT NULL,
    member_id   NUMBER          NOT NULL,
    content     VARCHAR2(1000)  NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_comment PRIMARY KEY (comment_id),
    CONSTRAINT fk_comment_board FOREIGN KEY (board_id) REFERENCES board_tb(board_id) ON DELETE CASCADE,
    CONSTRAINT fk_comment_member FOREIGN KEY (member_id) REFERENCES member_tb(member_id) ON DELETE CASCADE
);

CREATE SEQUENCE comment_seq START WITH 1 INCREMENT BY 1 NOCACHE;

-- =============================================
-- 확인
-- =============================================
SELECT table_name FROM user_tables ORDER BY table_name;
