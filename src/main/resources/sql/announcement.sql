-- =============================================
-- 공지사항 테이블 (관리자 작성)
-- Oracle DB / HR 계정에서 실행
-- =============================================

CREATE TABLE announcement_tb (
    announcement_id NUMBER          NOT NULL,
    member_id       NUMBER          NOT NULL,
    title           VARCHAR2(200)   NOT NULL,
    content         CLOB            NOT NULL,
    view_cnt        NUMBER          DEFAULT 0 NOT NULL,
    reg_date        DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_announcement PRIMARY KEY (announcement_id),
    CONSTRAINT fk_announcement_member FOREIGN KEY (member_id)
        REFERENCES member_tb(member_id) ON DELETE CASCADE
);

CREATE SEQUENCE announcement_seq START WITH 1 INCREMENT BY 1 NOCACHE;

COMMIT;
