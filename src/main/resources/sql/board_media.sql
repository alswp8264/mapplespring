-- =============================================
-- 게시판: 카테고리 컬럼 + 첨부파일(이미지/동영상) 테이블
-- Oracle DB / HR 계정에서 실행
-- =============================================

-- 1) 게시판 카테고리 컬럼 (공략/전사/도적/마법사/해적/궁수)
ALTER TABLE board_tb ADD (category VARCHAR2(20));

-- 2) 첨부파일 테이블
--    file_name: 서버 저장 파일명(UUID)
--    orig_name: 원본 파일명
--    file_type: image 또는 video
CREATE TABLE board_file_tb (
    file_id    NUMBER          NOT NULL,
    board_id   NUMBER          NOT NULL,
    file_name  VARCHAR2(200)   NOT NULL,
    orig_name  VARCHAR2(300),
    file_type  VARCHAR2(10),
    reg_date   DATE            DEFAULT SYSDATE NOT NULL,
    CONSTRAINT pk_board_file PRIMARY KEY (file_id),
    CONSTRAINT fk_board_file_board FOREIGN KEY (board_id)
        REFERENCES board_tb(board_id) ON DELETE CASCADE
);

CREATE SEQUENCE board_file_seq START WITH 1 INCREMENT BY 1 NOCACHE;

COMMIT;
