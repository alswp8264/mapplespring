-- =============================================
-- 게시글 신고 + 회원 밴(글쓰기 제한)
-- Oracle DB / HR 계정에서 실행
-- =============================================

-- 1) 회원 밴 만료 시각 (이 시각 전까지 글/댓글 작성 불가)
ALTER TABLE member_tb ADD (ban_until DATE);

-- 2) 신고 테이블
--    status: PENDING(대기) / DONE(처리됨)
CREATE TABLE report_tb (
    report_id   NUMBER          NOT NULL,
    board_id    NUMBER          NOT NULL,
    reporter_id NUMBER          NOT NULL,
    reason      VARCHAR2(500),
    status      VARCHAR2(10)    DEFAULT 'PENDING' NOT NULL,
    reg_date    DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_report PRIMARY KEY (report_id),
    CONSTRAINT fk_report_board  FOREIGN KEY (board_id)    REFERENCES board_tb(board_id)   ON DELETE CASCADE,
    CONSTRAINT fk_report_member FOREIGN KEY (reporter_id) REFERENCES member_tb(member_id) ON DELETE CASCADE
);

CREATE SEQUENCE report_seq START WITH 1 INCREMENT BY 1 NOCACHE;

COMMIT;
