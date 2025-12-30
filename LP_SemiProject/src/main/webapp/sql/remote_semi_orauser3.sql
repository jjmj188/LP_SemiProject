show user;
--USER이(가) "SEMI_ORAUSER3"입니다.


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
  ,status             number(1) default 1 not null     -- 회원탈퇴유무   1: 사용가능(가입중) / 0:사용불능(탈퇴) 
  , point             NUMBER DEFAULT 0 -- 포인트
  ,idle               number(1) default 0 not null     -- 휴면유무      0 : 활동중  /  1 : 휴면중 
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

commit;
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
  , reviewcontent VARCHAR2(1000) -- 리뷰내용
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

select *
from tbl_product;

select *
from tbl_track;


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

ALTER TABLE tbl_product MODIFY productdesc VARCHAR2(4000);
commit;
insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
1, 
1, 
'Charlie Puth (찰리 푸스) - 1집 Nine Track Mind [LP]',
'/images/productimg/1.jpg',
20,
28300, 
'빌보드 싱글 차트 12주 1위 곡 See You Again 
히트 싱글 One Call Away
빌보드 싱글 차트 탑 10 We Don’t Talk Anymore로 성장해가고 있는 차세대 초대형 팝 스타 찰리 푸스 Charlie Puth
전 세계를 사로잡은 One Call Away, Marvin Gaye, We Don`t Talk Anymore, See You Again 등', 
'https://www.youtube.com/watch?v=CTMTEAXlHow',
TO_DATE('2025-01-01', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
2, 
1, 
'Madison Beer (매디슨 비어) - locket [LP] ',
'/images/productimg/2.png',
20,
56500, 
'그래미상 2회 후보 지명 및 플래티넘 판매 기록을 보유한 다재다능한 아티스트 매디슨 비어가 차기 스튜디오 앨범 `locket`을 에픽 레코드를 통해 2026년 1월 16일에 발매를 발표했다.
매디슨 비어가 직접 작사, 작곡 및 공동 프로듀싱을 맡은 이번 앨범에는 오랜 협력자인 원 러브( One Love) , 로스트보이(LOSTBOY) , 그리고 르로이 클램핏(Leroy Clampitt) 이 프로듀싱에 참여했다. `locket`에는 비어가 2025년에 발표한 히트곡 ` bittersweet `(비어의 곡 중 가장 빠르게 빌보드 Top 40에 진입)와 ` yes baby `가 수록되어 있다.

비어는 앨범 제목  `locket` 을 작곡 초기부터 염두에 두고 있었으며, 앨범 제목처럼 과거의 기억과 경험을 모자이크처럼 엮어낸 팝 사운드를 선보인다. 비어의 작곡가, 가수, 프로듀서로서의 성장을 보여주는 앨범 `locket`에는 그녀의 커리어에서 가장 역동적인 보컬을 자랑하는 곡들이 수록되어 있다.', 
'https://youtu.be/J0Hntayn9vw?si=tYmk1kAD0oi_eMlb',
TO_DATE('2025-01-02', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
3, 
1, 
'Michael Buble (마이클 부블레) - Christmas [레드 컬러 LP]',
'/images/productimg/3.png',
20,
62400, 
'크리스마스 캐럴의 대세!
이 시대 최고의 로맨틱 보이스 마이클 부블레의 크리스마스 앨범 LP 발매.

로맨틱 보컬리스트 마이클 부블레가 준비한 크리스마스 앨범 [Christmas]는 David Foster, Bob Rock 그리고 Humberto Gatica 등 최고의 프로듀서와 편곡자가 참여하여 만든 높은 퀄리티의 크리스마스 기획 앨범이다.
총 15곡이 수록된 [Christmas]에는 - `It`s Beginning To Look a Lot Like Christmas`, `Have Yourself a Merry Little Christmas`, 등의 클래식 크리스마스 캐럴부터 머라이어 캐리의 `All I Want for Christmas is You`를 마이클 부블레 스타일로 전혀 새로게 편곡한 곡과 최고 여성 컨트리 싱어 Shania Twain과 듀엣으로 부른 `White Christmas` 그리고 멕시코 출신의 디바 Thalia와 함께한 `Feliz Navidad`가 담겨있다.', 
'https://youtu.be/QJ5DOWPGxwg?si=IxcuLdkhWFKhzPNk',
TO_DATE('2014-10-30', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
4, 
1, 
'Rachael Yamagata (레이첼 야마가타) - Starlit Alchemy [LP]',
'/images/productimg/4.png',
20,
51400, 
'레이첼 야마가타 [스타릿 알케미]
Rachael Yamagata [Starlit Alchemy] 1LP 한정반

2004년 비평가들의 찬사를 받은 데뷔 앨범 Happenstance로 음악계에 등장한 이후, 한국에서도 많은 사랑을 받아온 싱어송라이터 레이첼 야마가타.
2025년에 선보이는 신작은 그래미상 후보에 세 차례 오른 존 알라지아와의 공동 프로듀스로 만들어졌다. 색소폰, 만돌린, 프랑스어 낭독, 금속 다리미판과 사다리 드럼, 루프, 중첩된 화성 등 새로운 사운드와 함께 만들어낸 그녀의 노래들을 만날 수 있다.', 
'https://youtu.be/VHkz6oYRV54?si=oIiaChhuDkOeL-yi',
TO_DATE('2025-10-23', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
5, 
1, 
'Benson Boone (벤슨 분) - Pulse [컬러 LP]',
'/images/productimg/5.png',
20,
53000, 
'조회수 1억 틱톡 팔로워 330만을 확보한 인플루언서인 미국 워싱턴 출신의 싱어송라이터 Benson Boone의 2023년 신작.
2022년 국내 팝 페스티벌에서 인상적인 라이브를 들려주며 한층 인기몰이를 하고 있는 그의 새 앨범에는 흥겨운 비트와 그의 감미로운 보이스가 돋보이는 ‘Lovely Darling’를 비롯하여 어쿠스틱한 인트로와 드라마틱한 클라이막스가 일품인 ‘What Was’ 가성과 진성을 넘나드는 진솔한 가창력을 느낄수 있는 아름다운 러브송 `Little Runaway` 등 이 수록되어 있다. 본 작품은 2025년 RSD를 기념하여 컬러 LP 한정으로 발매되어 한층 높은 소장가치를 전해준다.', 
'https://youtu.be/ar-DnXZuMqE?si=p-o8IkHMWCwXhCfz',
TO_DATE('2025-12-19', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
6, 
1, 
'Mariah Carey (머라이어 캐리) - 3집 Music Box [LP]',
'/images/productimg/6.png',
20,
39700, 
'팝의 여왕 머라이어 캐리 데뷔 30 주년 기획! Vinyl 리이슈반.
1993년에 발매된 앨범으로 미국 앨범 차트 1위를 기록!
미국 싱글 차트 8주 연속 1위를 기록한 `Dreamlove`를 비롯하여 4주 연속 1위를 차지한 `Hero`등이 수록되어 있다', 
'https://youtu.be/nNF_7UieFYQ?si=bjxrEiQ3zb6KJicJ',
TO_DATE('2020-11-10', 'YYYY-MM-DD'),
10);

SET DEFINE OFF;
insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
7, 
1, 
'Olivia Rodrigo (올리비아 로드리고) - Live From Glastonbury (A BBC Recording) [컬러 2LP]',
'/images/productimg/7.png',
20,
69000, 
'2024년 9월 앨범 [GUTS] 투어차 한국에서 공연을 갖은 바 있는 팝스타 Olivia Rodrigo의 첫번째 라이브 앨범 Live From Glastonbury (A BBC Recording)[Light Blue & Cobald 2LP]!

2025년 6월 29일 영국 글라스톤베리 무대의 노래를 모두 담은 앨범으로 2021년 데뷰 히트 싱글 `Drivers License`를 비롯해 `Deja Vu`, `Good 4 U`, `Vampire`등의 히트곡들과 무대에 함께 올랐던 레전드 그룹 Cure의 Robert Smith와 듀엣으로 부른 `Friday I`m in Love`, `Just Like Heaven`이 수록되어 있다.', 
'https://youtu.be/WkLqgkW9h_w?si=E3atC_YTj-sZsoUA',
TO_DATE('2025-12-05', 'YYYY-MM-DD'),
10);

commit;

select *
from tbl_product;

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
8, 
1, 
'Taylor Swift (테일러 스위프트) - 1집 Taylor Swift',
'/images/productimg/8.png',
20,
32000, 
'Shania Twain, Faith Hill, Martina McBride의 계보를 잇는 최고의 컨템포러리 컨츄리 팝스타 
Taylor Swift의 2006년 셀프타이틀 데뷰작 [Taylor Swift]!!! 2006년 10월 24일 발매되어 빌보드 컨츄리 앨범차트 1위, 팝 앨범차트 5위까지 오르며 미국에서만 4백만장 이상 판매되는 빅히트를 기록한 음반!
2006년 첫 싱글 ''Tim McGraw''를 시작으로 2007년 ''Teardrops on My Guitar'', ''Our Song'', ''Picture to Burn'', ''Should''ve Said No''등 무려 5곡의 싱글 히트!', 
'https://youtu.be/SL5FFdAvaIA?si=d1KJfYN4tCSsAII9',
TO_DATE('2009-11-13', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
9, 
1, 
'Abba (아바) - Gold: Greatest Hits [2LP]',
'/images/productimg/9.png',
20,
80200, 
'지난 2008년부터 시작되어 6년째를 맞이하고 있는 유니버설 뮤직 LP 재발매 캠페인 [Back To Black] 뉴 시리즈! 
1992년 발매되어 스웨덴, 영국, 일본, 스위스, 호주, 독일, 노르웨이등 많은 나라의 앨범차트 1위에 오르며
Abba의 베스트 앨범중 전세계적으로 가장 많이 팔아치운 Gold - Greatest Hits [180g][2LP][Back To Black Series][Free MP3 Download]! 
한국인이 가장 좋아하는 Abba의 대표 싱글 ''Dancing Queen''을 시작으로 뮤지컬로 사랑받아오고 있는 ''Mamma Mia'', 아름다운 유로팝 발라드 넘버 ''I Have a Dream'', 서정적인 하모니로 사랑받았던 ''Fernando''등 총 19곡 수록! (본 음반은 LP로 처음 발매됨)', 
'https://youtu.be/2ZUX3j6WLiQ?si=N2yFr2rRpXHr8t4y',
TO_DATE('2014-07-15', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
10, 
1, 
'The Beatles (비틀즈) - Abbey Road [그린 컬러 LP]',
'/images/productimg/10.png',
20,
56500, 
'팝 역사상 가장 위대한 밴드, 비틀즈의 최고의 명반으로 불리우는 [Abbey Road] Green Vinyl 리미티드 에디션.
비틀즈가 마지막으로 녹음한 앨범으로 조지 해리스의 명곡인 ''Something''을 비롯하여 링고 스타의 대표작인 ''Octopus''s Garden'' , 전세계 적으로 힛트를 기록한 ''Come Together''등이 수록된 앨범.', 
'https://youtu.be/oolpPmuK2I8?si=PiqRGKTXgmOVWVy1',
TO_DATE('2025-11-19', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
11, 
1, 
'Teddy Swims (테디 스윔스) - I''ve Tried Everything But Therapy',
'/images/productimg/11.png',
20,
38100, 
'마치 남성판 아델을 연상시키는 파워풀한 가창력과 애절한 보이스 소울 음악을 들려주며 
최근 커다란 화제몰이를 하고 있는 백인 싱어송라이터 Teddy Swims의 2023년 데뷔 그리고 2025년 발표한 Part.2를 합본으로 수록한 앨범. 

파워플한 소울팝 넘버 인 첫번째 싱글 ''What More Can I Say''를 비롯하여 ''Lose Control'', ''Evergreen'' 
그리고 GIVEON과 함께한 ‘Are You Even Real’, Coco Jones & GloRilla와 함께한 ‘She Got It’ 등의 히트 싱글과 미공개 보너스 트랙 6곡이 수록 한층 높은 만족감을 전해준다.', 
'https://youtu.be/9_HsHw9uPJg?si=A1xzDqyJXpFOA9Hp',
TO_DATE('2025-12-20', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
12, 
1, 
'New Order (뉴 오더) - Power Corruption and Lies',
'/images/productimg/12.png',
20,
38100, 
'맨체스터 사운드의 전설 New Order의 ‘83년 앨범. 씬디사이져의 전면적인 도입으로 한층 밝아진 느낌의 일레트로닉 스타일을 선보인 
본 앨범은 Bernard Sumner의 안정적인 보이스와 쟁글거리는 기타의 조합이 이채로운 ‘Age of Consent’를 비롯하여 완전한 씬스팝 사운드를 들려주는 ‘The Village’, 경쾌한 베이스 라인과 오토튠의 코러스가 매력적인 ‘Ecstasy’ 등의 작품이 수록.
2024년 발매된 본 에디션은 새로운 마스터링의 음질과 더불어 미공개 음원 17곡이 수록된 2CD로 제작 높은 소장가치를 전해준다.', 
'https://youtu.be/gG9fEaITgCk?si=dG-_8Xia_Balbnak',
TO_DATE('2025-12-19', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
13, 
1, 
'Damien Rice - Live From The Union Chapel (Korea Tour Edition)',
'/images/productimg/13.png',
20,
16500, 
'치명적 중독, 깊은 서정미의 진수 데미안 라이스
국내 미발매 트랙 2곡 포함, 전 세계 최초 및 단독 발매!
Live From The Union Chapel [+ 2 Studio Tracks : Korea Tour Edition](디지팩)
그 동안 구입하기 힘들었던 데미안 라이스의 라이브 EP "Live From The Union Chapel" 가 첫 내한 공연을 기념해 전세계 최초 및 단독으로 스튜디오 트랙 2곡이 추가 수록 되어 슬리브 케이스가 아닌 디지팩으로 특별 제작 발매된다.
데미안 라이스와 객원보컬 리사 해니건의 매력적인 음성을 감상할 수 있는 라이브 8곡, 그리고 보너스 트랙으로 ''The Rat Within The Grain'', 리사 해니건과 함께 만든 서정적인 듀엣곡 ''Unplayed Piano'' 등 총
10곡이 수록된다. (''Unplayed Piano''은 아웅산 수지 여사에게 헌정한 곡이기도 하다.)', 
'https://youtu.be/RUXKCak6n2k?si=BSbE98sKUoapHNGj',
TO_DATE('2011-12-28', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
14, 
1, 
'Lady Gaga (레이디 가가) - MAYHEM]',
'/images/productimg/14.png',
20,
35300, 
'팝적인 근원으로의 복귀를 담은 앨범 [Mayhem]은 그녀의 다양한 에너지와 두려움 없는 예술적 비전이 결합되어 그녀의 초기 사운드를 재창조했다. 
약 1억 7천만 장의 음반을 판매한 Lady Gaga는 세계에서 가장 많이 팔린 음악가 중 한 명이다. 
전 세계적으로 각각 1천만 장 이상 판매된 싱글 4개를 보유한 유일한 여성 아티스트이자 그녀의 스튜디오 앨범 6장이 미국 Billboard 200에서 1위를 차지했다.
Lady Gaga, Andrew Watt, Cirkut, Gesaffelstein이 프로듀스한 신작에는 그래미 어워드 Best Pop Duo/Group Performance 수상 및 빌보드 싱글 차트 1위를 기록한 Bruno Mars와의 듀엣곡 ''Die With A Smile'', 리드 싱글 ''Disease'', 두 번째 싱글 ''Abracadabra'' 포함 총 14곡이 수록되어 있다.', 
'https://youtu.be/vBynw9Isr28?si=bMDIWTkH6dQvjaGw',
TO_DATE('2025-04-02', 'YYYY-MM-DD'),
10);

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
15, 
1, 
'Conan Gray (코난 그레이) - 3집 Found Heaven',
'/images/productimg/15.png',
20,
33700, 
'Z 세대를 대표하는 베드룸 팝의 아이콘, Conan Gray의 2024년 세번째 정규 앨범 [Found Heaven]!

2022년 두번째 앨범 [Superache]이후 2년만의 신작으로 Taylor Swift, Ariana Grande와 함께 일했던 프로듀서 Max Martin를 비롯해 Greg Kurstin, Ilya, Shawn Everett등이 
프로듀싱에 참여, 신스, 댄스팝 앨범을 선보였다. 앨범에는 작년 5월에 선공개 했던 첫 싱글 ''Never Ending Song''을 비롯해 ''Winner'', ''Killing Me'', 올해 공개되었던 ''Lonely Dancers'', ''Alley Rose''등 신곡 13곡을 수록하고 있다.', 
'https://youtu.be/0RRKXGhDTOo?si=2C7leFwDMvser7lK',
TO_DATE('2024-05-24', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
16, 
1, 
'Ariana Grande (아리아나 그란데) - 7집 eternal sunshine',
'/images/productimg/16.png',
20,
24600, 
'아리아나 그란데 일곱 번째 정규 앨범 [eternal sunshine]
영원한 햇살처럼 쏟아져 내리는 아리아나 그란데의 눈부신 이야기 하나의 관계가 무너진 후 새로운 관계를 시작하며 인생을 치유하는 과정을 담아낸 앨범
발매와 동시에 빌보드 HOT100 차트1위! 빌보드 200 차트 1위!', 
'https://youtu.be/p7jATa6Soag?si=FO42pXFYHWdFhr6_',
TO_DATE('2024-03-29', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
17, 
1, 
'Taylor Swift (테일러 스위프트) - 9집 Evermore',
'/images/productimg/17.png',
20,
28800, 
'현존하는 최고의 여성 팝스타 Taylor Swift의 2020년 9번째 정규 앨범 Evermore [Deluxe Edition]!

8번째 정규 앨범 [Folklore] 이후 5개월이 채 되지 않아 발매한 앨범 [Evermore]는 [Folklore] 앨범의 확장 버전이자 자매 앨범으로 알려져 있다.

전작의 인디/포크 사운드를 확장한 앨범 [Evermore]는 핑거 픽 기타, 부드러운 피아노 및 현악기의 희박한 배열을 중심으로 만들어진 겨울의 얼터너티브 록 및 챔버 록 앨범이다.

Aaron Dessner, Jack Antonoff, WB 및 Justin Vernon과 함께 제작한 앨범 [Evermore]에는 차가운 챔버 포크 러브 송 ''Willow'', The National의 Matt Berninger와 함께하는 얼터너티브 록 ''Coney Island'', 크리스마스 곡 ''Tis the Damn Season'', Smiths의 ''Asleep''을 모호하게 연상시키는 ''Tolerate It'' 등 15곡의 정규 트랙과 함께 보너스 트랙 2곡 포함 총 17곡이 수록되어 있다.', 
'https://youtu.be/RQQRX718tUg?si=_4wwFPHsyR8R_Vfx',
TO_DATE('2021-01-12', 'YYYY-MM-DD'),
10);

commit;

insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
18, 
1, 
'Ginger Root (진저 루트) - SHINBANGUMI [컬러 LP]',
'/images/productimg/18.png',
20,
51700, 
'Ginger Root는 멀티 악기 연주자, 프로듀서, 작곡가, 그리고 비주얼 아티스트인 Cameron Lew의 프로젝트이다. 
Ginger Root는 대망의 세 번째 앨범인 [SHINBANGUMI]를 그의 새로운 레이블인 Ghostly International에서 발매한다.', 
'https://youtu.be/_J5YJCxh3FY?si=_6gI-da1hVr7FULB',
TO_DATE('2022-11-11', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
19, 
1, 
'Michael Jackson - Xscape',
'/images/productimg/19.png',
20,
24300,
'“팝의 황제” 마이클 잭슨! 기다리던 마이클 잭슨의 새로운 음악! 
XSCAPE 에픽 레코드의 수장 "엘 에이 리드" (L.A. Reid)와 최고의 프로듀서들이 의기투합해 "현대화"한 마이클 잭슨의 신곡들! 
음원 공개 후 팬들에게 폭발적인 지지를 얻고 있는 ‘Slave To The Rhythm’ , ‘Love Never Felt So Good’ , ‘Xscape’등 총 8곡이 수록된 스탠다드 앨범', 
'https://youtu.be/TTzD6gWV16s?si=NWgz412nWjzyERbB',
TO_DATE('2014-05-16', 'YYYY-MM-DD'),
10);


insert into tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
values(
20, 
1, 
'Sabrina Carpenter (사브리나 카펜터) - Fruitcake [올리브 그린 컬러 LP]',
'/images/productimg/20.png',
20,
59400,
'Ariana Grande를 잇는 팝계의 프린세스 Sabrina Carpenter의 2023년 발표했던 캐롤 EP 앨범 Fruitcake [EP][Olive Green LP]!

2023년에 디지털 EP로 2024년에 피지컬 음반으로 발매되었던 음반으로 One Direction과 작업했던 프로듀서 Julian Bunetta와 John Ryan이 프로듀싱했다. 
2023년 디지털 음원 발매 당시 빌보드 앨범차트 10위까지 올랐으며 싱글 ''A Nonsense Christmas''를 포함 총 6곡 수록!', 
'https://youtu.be/geOBEIH1H30?si=Dxi0dhVg6wHZro2n',
TO_DATE('2025-11-14', 'YYYY-MM-DD'),
10);

select *
from tbl_track;

commit;

-- 1번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (1, 1, 1, 'One Call Away');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (2, 1, 2, 'Dangerously'); 
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (3, 1, 3, 'Dangerously'); 
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (4, 1, 4, 'Marvin Gaye (feat. Meghan Trainor)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (5, 1, 5, 'We Don''t Talk Anymore (feat. Selena Gomez)');

-- 2번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (6, 2, 1, 'locket Theme (locket)');

-- 3번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (7, 3, 1, 'It''s Beginning To Look A Lot Like Christmas');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (8, 3, 2, 'Santa Claus Is Coming To Town');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (9, 3, 3, 'Jingle Bells Featuring The Puppini Sisters');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (10, 3, 4, 'White Christmas (Duet With Shania Twain)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (11, 3, 5, 'All I Want For Christmas Is You');


-- 4번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (12, 4, 1, 'Backwards');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (13, 4, 2, 'Birds');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (14, 4, 3, 'Carnival');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (15, 4, 4, 'Heaven Help');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (16, 4, 5, 'Empty Houses');

-- 5번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (17, 5, 1, 'Coffee Cake');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (18, 5, 2, 'Lovely Darling');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (19, 5, 3, 'What Was');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (20, 5, 4, 'Sugar Sweet');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (21, 5, 5, 'Little Runaway');

-- 6번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (22, 6, 1, 'Dreamlover');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (23, 6, 2, 'Hero');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (24, 6, 3, 'Anytime You Need A Friend');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (25, 6, 4, 'Music Box');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (26, 6, 5, 'Now That I Know');

-- 7번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (27, 7, 1, 'Obsessed');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (28, 7, 2, 'Ballad of a Homeschooled Girl');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (29, 7, 3, 'Vampire');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (30, 7, 4, 'Drivers License');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (31, 7, 5, 'Traitor');

-- 8번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (32, 8, 1, 'Tim McGraw');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (33, 8, 2, 'Picture To Burn');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (34, 8, 3, 'Teardrops On My Guitar');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (35, 8, 4, 'A Place In This World');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (36, 8, 5, 'Cold As You');

-- 9번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (37, 9, 1, 'Dancing Queen (03:51)(Side A)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (38, 9, 2, 'Knowing Me, Knowing You (04:02)(Side A)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (39, 9, 3, 'Take A Chance On Me (04:03)(Side A)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (40, 9, 4, 'Mamma Mia (03:32)(Side A)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (41, 9, 5, 'Lay All Your Love On Me (04:34)(Side A)');

-- 10번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (42, 10, 1, 'Come Together');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (43, 10, 2, 'Something');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (44, 10, 3, 'Maxwell’s Silver Hammer');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (45, 10, 4, 'Oh! Darling');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (46, 10, 5, 'Octopus’s Garden');

-- 11번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (47, 11, 1, 'Some Things I''ll Never Know');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (48, 11, 2, 'Lose Control');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (49, 11, 3, 'What More Can I Say');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (50, 11, 4, 'The Door');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (51, 11, 5, 'Goodbye''s Been Good to You');

-- 12번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (52, 12, 1, 'Age of Consent (2020 Remaster)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (53, 12, 2, 'We All Stand (2020 Remaster)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (54, 12, 3, 'The Village (2020 Remaster)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (55, 12, 4, '5 8 6 (2020 Remaster)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (56, 12, 5, 'Your Silent Face (2020 Remaster)');

-- 13번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (57, 13, 1, 'Delicate');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (58, 13, 2, 'The Blower''s Daughter');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (59, 13, 3, 'Volcano');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (60, 13, 4, 'Then Go');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (61, 13, 5, 'Baby Sister');

-- 14번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (62, 14, 1, 'Disease');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (63, 14, 2, 'Abracadabra');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (64, 14, 3, 'Garden Of Eden');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (65, 14, 4, 'Perfect Celebrity');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (66, 14, 5, 'Vanish Into You');

-- 15번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (67, 15, 1, 'Found Heaven');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (68, 15, 2, 'Never Ending Song');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (69, 15, 3, 'Fainted Love');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (70, 15, 4, 'Lonely Dancers');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (71, 15, 5, 'Alley Rose');

-- 16번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (72, 16, 1, 'Intro (End Of The World)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (73, 16, 2, 'Bye');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (74, 16, 3, 'Don''t Wanna Break Up Again');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (75, 16, 4, 'Saturn Returns Interlude');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (76, 16, 5, 'Eternal Sunshine');

-- 17번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (77, 17, 1, 'Willow');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (78, 17, 2, 'Champagne Problems');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (79, 17, 3, 'Gold Rush');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (80, 17, 4, '‘Tis The Damn Season');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (81, 17, 5, 'Tolerate It');

-- 18번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (82, 18, 1, 'Welcome');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (83, 18, 2, 'No Problems');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (84, 18, 3, 'Better Than Monday');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (85, 18, 4, 'There Was A Time');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (86, 18, 5, 'All Night');

-- 19번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (87, 19, 1, 'Love Never Felt So Good');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (88, 19, 2, 'Chicago');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (89, 19, 3, 'Loving You');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (90, 19, 4, 'A Place With No Name');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (91, 19, 5, 'Slave to the Rhythm');

-- 20번 트랙
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (92, 20, 1, 'A Nonsense Christmas');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (93, 20, 2, 'Buy Me Presents');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (94, 20, 3, 'Santa Doesn''t Know You Like I Do');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (95, 20, 4, 'Cindy Lou Who');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (96, 20, 5, 'Is It New Years Yet?');

