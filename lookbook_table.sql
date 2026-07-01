-- ============================================================
-- Oracle HR 계정으로 실행 (SQL Developer 또는 SQL*Plus)
-- ============================================================

CREATE TABLE lookbook_tb (
    lookbook_id  NUMBER          PRIMARY KEY,
    member_id    NUMBER          NOT NULL,
    char_name    VARCHAR2(50)    NOT NULL,
    char_image   VARCHAR2(500),
    char_class   VARCHAR2(50),
    char_world   VARCHAR2(50),
    char_level   NUMBER          DEFAULT 0,
    title        VARCHAR2(200),
    reg_date     DATE            DEFAULT SYSDATE,
    CONSTRAINT fk_lookbook_member FOREIGN KEY (member_id) REFERENCES member_tb(member_id)
);

CREATE SEQUENCE lookbook_seq START WITH 1 INCREMENT BY 1 NOCACHE;

COMMIT;
