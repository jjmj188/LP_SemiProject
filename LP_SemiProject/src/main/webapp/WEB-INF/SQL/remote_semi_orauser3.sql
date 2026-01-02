show user;
-- USER이(가) "SEMI_ORAUSER3"입니다.


  
--회원테이블
CREATE TABLE tbl_member
(
    userid            VARCHAR2(40) NOT NULL -- 회원아이디(PK) 
  , pwd               VARCHAR2(200) NOT NULL -- 비밀번호 : SHA-256 암호화 저장
  , name              VARCHAR2(30) NOT NULL -- 회원명 
  , email             VARCHAR2(200) NOT NULL -- 이메일 : AES-256 암호화 대상, 중복 불가
  , mobile            VARCHAR2(200) -- 휴대폰번호 : AES-256 암호화 대상
  , gender            VARCHAR2(1) -- 성별 : 남자(1), 여자(2)
  , birthday          VARCHAR2(10) -- 생년월일 
  , registerday       DATE DEFAULT SYSDATE -- 가입일자 
  , lastpwdchangedate DATE DEFAULT SYSDATE -- 마지막암호변경날짜시각 
  , status             number(1) default 1 not null     -- 회원탈퇴유무   1: 사용가능(가입중) / 0:사용불능(탈퇴) 
  , point             NUMBER DEFAULT 0 -- 포인트
  , idle               number(1) default 0 not null     -- 휴면유무      0 : 활동중  /  1 : 휴면중 
  , CONSTRAINT PK_tbl_member_userid PRIMARY KEY (userid)  
  , CONSTRAINT UQ_tbl_member_email UNIQUE (email) -- 이메일 중복 방지
  , CONSTRAINT CK_tbl_member_gender CHECK (gender IN ('1','2')) -- 성별   남자:1  / 여자:2
  , CONSTRAINT CK_tbl_member_status CHECK (status IN (0,1)) -- 회원탈퇴유무 값 제한
  ,constraint CK_tbl_member_idle check( idle in(0,1) )
);




--로그인 기록 테이블
create table tbl_loginhistory
(historyno   number
,fk_userid   varchar2(40) not null  -- 회원아이디
,logindate   date default sysdate not null -- 로그인되어진 접속날짜및시간
,clientip    varchar2(20) not null -- 접속한 클라이언트 IP 주소
,constraint  PK_tbl_loginhistory primary key(historyno) 
,constraint  FK_tbl_loginhistory_fk_userid foreign key(fk_userid) references tbl_member(userid)
);


create sequence seq_historyno
start with 1
increment by 1
nomaxvalue
nominvalue
nocycle
nocache;

-- 카테고리 테이블
CREATE TABLE tbl_category
(
    categoryno NUMBER -- 카테고리분류번호(PK) 
  , categoryname VARCHAR2(50) NOT NULL -- 카테고리명 (POP, ROCK, JAZZ, CLASSIC, ETC)
  , CONSTRAINT PK_tbl_category PRIMARY KEY (categoryno)
);

select * from  tbl_category;

-- 초기데이터
INSERT INTO tbl_category VALUES (1, 'POP');
INSERT INTO tbl_category VALUES (2, 'ROCK');
INSERT INTO tbl_category VALUES (3, 'JAZZ');
INSERT INTO tbl_category VALUES (4, 'CLASSIC');
INSERT INTO tbl_category VALUES (5, 'ETC');


-- 회원취향테이블
CREATE TABLE tbl_member_preference
(
    fk_userid     VARCHAR2(40) NOT NULL -- 회원아이디 (FK)
  , fk_categoryno NUMBER NOT NULL       -- 카테고리 번호 (FK)

  -- 한 회원이 같은 취향을 중복 선택하지 못하도록 복합 PK 설정
  , CONSTRAINT PK_tbl_member_preference
        PRIMARY KEY (fk_userid, fk_categoryno)

  -- 회원 테이블 참조
  , CONSTRAINT FK_tbl_member_preference_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)

  -- 카테고리 테이블 참조
  , CONSTRAINT FK_tbl_member_preference_category
        FOREIGN KEY (fk_categoryno)
        REFERENCES tbl_category(categoryno)
);

 
-- 제품 테이블
CREATE TABLE tbl_product
(
    productno NUMBER -- 제품번호(PK) 
  , fk_categoryno NUMBER NOT NULL -- 카테고리분류번호(FK) : tbl_category.categoryno 참조
  , productname VARCHAR2(100) NOT NULL -- 제품명 
  , productimg VARCHAR2(200) -- 제품이미지 
  , stock NUMBER DEFAULT 20 -- 제품재고량 : 현재 판매 가능한 재고 수량: 20개
  , price NUMBER NOT NULL -- 제품판매가격 
  , productdesc VARCHAR2(1000) -- 제품설명 
  , youtubeurl VARCHAR2(300) -- 제품 유튜브 URL : 관련 영상 링크
  , registerday DATE DEFAULT SYSDATE -- 발매일
  , point NUMBER DEFAULT 10 -- 포인트 점수 : 구매 시 적립 포인트:10 포인트
  , CONSTRAINT PK_tbl_product
        PRIMARY KEY (productno)
  , CONSTRAINT FK_tbl_product_category
        FOREIGN KEY (fk_categoryno)
        REFERENCES tbl_category(categoryno)
);

CREATE SEQUENCE seq_productno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;

--곡 리스트
CREATE TABLE tbl_track (
    trackno        NUMBER        PRIMARY KEY,        -- 곡 번호 (PK)
    fk_productno   NUMBER        NOT NULL,           -- 제품 번호 (앨범 번호, FK)
    track_order    NUMBER        NOT NULL,           -- 앨범 내 곡 순서 01, 02.....
    track_title    VARCHAR2(200) NOT NULL,           -- 곡 제목

    CONSTRAINT fk_track_product
      FOREIGN KEY (fk_productno)
      REFERENCES tbl_product(productno)              -- 제품(앨범) 테이블과 연결
);

CREATE SEQUENCE seq_trackno
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- 찜 테이블
CREATE TABLE tbl_wishlist
(
    fk_userid  VARCHAR2(40) NOT NULL -- 회원아이디(FK) : tbl_member.userid 참조

  , fk_productno NUMBER NOT NULL -- 제품번호(FK) : tbl_product.productno 참조

  , CONSTRAINT PK_tbl_wishlist
        PRIMARY KEY (fk_userid, fk_productno) -- 복합 기본키 : 회원아이디 + 제품번호

  , CONSTRAINT FK_tbl_wishlist_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)

  , CONSTRAINT FK_tbl_wishlist_product
        FOREIGN KEY (fk_productno)
        REFERENCES tbl_product(productno)
);


-- 장바구니 테이블
CREATE TABLE tbl_cart
(
    cartno NUMBER -- 장바구니 번호(PK)
  , fk_userid VARCHAR2(40) NOT NULL -- 회원아이디(FK) : tbl_member.userid 참조
  , fk_productno NUMBER NOT NULL -- 제품번호(FK) : tbl_product.productno 참조
  , qty NUMBER DEFAULT 1 NOT NULL -- 수량 : 장바구니에 담은 제품 수량
  , CONSTRAINT PK_tbl_cart
        PRIMARY KEY (cartno)
  , CONSTRAINT FK_tbl_cart_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
  , CONSTRAINT FK_tbl_cart_product
        FOREIGN KEY (fk_productno)
        REFERENCES tbl_product(productno)
  , CONSTRAINT UQ_tbl_cart_user_product
        UNIQUE (fk_userid, fk_productno) -- 같은 회원이 같은 제품을 중복 담지 못하도록 제한
);

CREATE SEQUENCE seq_cartno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;

-- 주문 테이블
CREATE TABLE tbl_order
(
    orderno NUMBER -- 주문번호(PK) 
  , fk_userid VARCHAR2(40) NOT NULL -- 회원아이디(FK) : tbl_member.userid 참조
  , totalprice NUMBER NOT NULL -- 주문총액 
  , usepoint NUMBER DEFAULT 0 -- 사용포인트 : 주문 시 사용한 포인트
  , totalpoint NUMBER DEFAULT 0 -- 주문총 포인트 : 주문으로 적립된 포인트
  , orderdate DATE DEFAULT SYSDATE NOT NULL -- 주문일자 
  , postcode VARCHAR2(5) -- 우편번호
  , address VARCHAR2(200) -- 주소
  , detailaddress VARCHAR2(200) -- 상세주소
  , extraaddress VARCHAR2(200) -- 주소참고항목
  , deliverystatus VARCHAR2(20) DEFAULT '배송준비중' -- 배송상태 : 배송준비중 / 배송중 / 배송완료
  , ordercomment VARCHAR2(500) -- 주문 문의내용 : 주문 관련 문의 사항
  , deliveryrequest VARCHAR2(500) -- 배송시 요청사항
  , CONSTRAINT PK_tbl_order
        PRIMARY KEY (orderno)
  , CONSTRAINT FK_tbl_order_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
 ,CONSTRAINT CK_tbl_order_deliverystatus
CHECK (deliverystatus IN ('배송준비중','배송중','배송완료'))

);

CREATE SEQUENCE seq_orderno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;




-- 주문상세 테이블
CREATE TABLE tbl_orderdetail
(
    orderdetailno NUMBER -- 주문상세 일련번호(PK)

  , fk_orderno NUMBER NOT NULL -- 주문번호(FK) : tbl_order.orderno 참조

  , fk_productno NUMBER NOT NULL -- 제품번호(FK) : tbl_product.productno 참조

  , qty NUMBER NOT NULL -- 주문량 

  , unitprice NUMBER NOT NULL -- 주문단가 

  , CONSTRAINT PK_tbl_orderdetail
        PRIMARY KEY (orderdetailno)

  , CONSTRAINT FK_tbl_orderdetail_orderno
        FOREIGN KEY (fk_orderno)
        REFERENCES tbl_order(orderno)

  , CONSTRAINT FK_tbl_orderdetail_product
        FOREIGN KEY (fk_productno)
        REFERENCES tbl_product(productno)
);

CREATE SEQUENCE seq_orderdetailno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;

-- 제품구매후기리뷰 테이블
CREATE TABLE tbl_review
(
    reviewno NUMBER -- 리뷰번호(PK)
  , fk_userid VARCHAR2(40) NOT NULL -- 회원아이디(FK) : tbl_member.userid 참조
  , fk_productno NUMBER NOT NULL -- 제품번호(FK) : tbl_product.productno 참조
  , rating NUMBER(1) NOT NULL -- 별점 : 1 ~ 5 점
  , reviewcontent VARCHAR2(100) -- 리뷰내용
  , writedate DATE DEFAULT SYSDATE NOT NULL -- 작성날짜
  , CONSTRAINT PK_tbl_review
        PRIMARY KEY (reviewno)
  , CONSTRAINT FK_tbl_review_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
  , CONSTRAINT FK_tbl_review_product
        FOREIGN KEY (fk_productno)
        REFERENCES tbl_product(productno)
  , CONSTRAINT CK_tbl_review_rating
        CHECK (rating BETWEEN 1 AND 5)
);

CREATE SEQUENCE seq_reviewno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;


-- 1:1 문의 테이블
CREATE TABLE tbl_inquiry
(
    inquiryno NUMBER -- 문의번호(PK)
  , fk_userid VARCHAR2(40) NOT NULL -- 회원아이디(FK) : tbl_member.userid 참조
  , inquirycontent VARCHAR2(1000) NOT NULL -- 문의내용
  , inquirydate DATE DEFAULT SYSDATE NOT NULL -- 문의 작성일
  , inquirystatus VARCHAR2(10) DEFAULT '대기' NOT NULL -- 문의상태 : 대기 / 완료
  , adminreply VARCHAR2(1000) -- 관리자답변
  , replydate DATE -- 답변일
  , CONSTRAINT PK_tbl_inquiry
        PRIMARY KEY (inquiryno)
  , CONSTRAINT FK_tbl_inquiry_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
  , CONSTRAINT CK_tbl_inquiry_status
        CHECK (inquirystatus IN ('대기','완료'))
);

CREATE SEQUENCE seq_inquiryno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;


-- 관리자 테이블
CREATE TABLE tbl_admin
(
    adminid VARCHAR2(40) -- 관리자 아이디(PK)
  , adminpwd VARCHAR2(200) NOT NULL -- 비밀번호 : SHA-256 암호화 저장
  , CONSTRAINT PK_tbl_admin
        PRIMARY KEY (adminid)
);

