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
from tbl_product
order by productno desc;

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





SET DEFINE OFF;

-- 21번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
21, 
2, 
'Radiohead (라디오헤드) - OK Computer: OKNOTOK 1997 2017 [3LP]', 
'/images/productimg/21.png', 
20, 
73800, 
'1997년 5월 21일 발매된 라디오헤드의 정규 3집 앨범. 록 음악의 가능성을 탐구해나간 사운드 실험의 결정판이자 라디오헤드의 대표작, 또한 1990년대를 대표하는 금자탑으로 평가 받는다. 밴드 역사상 최초로 UK 차트 1위를 기록했고, 1998년 그래미 어워드 올해의 앨범에 노미네이트 되었다. 미국 의회도서관(The Library of Congress)은 2015년에 이 앨범을 “문화적, 역사적, 미학적으로 중요한 위치”에 있다고 밝히며 국가적 녹음 기록물(National Recording Registry)로 선정했다.

변칙적 구성으로 무장한 ''Paranoid Android'', 영화 [로미오와 줄리엣, Romeo + Juliet]에 수록된 레퀴엠 ''Exit Music (For a Film)'', 여전히 사랑 받는 라디오헤드 최고의 발라드 ''No Surprises''는 대중성과 음악성 사이의 든든한 버팀목이 되었다. 특히 ''Karma Police''의 경우 오아시스(Oasis)의 노엘 갤러거(Noel Gallagher)가 자신의 베스트로 꼽기도 했으며, 모조 매거진의 경우 "만일 존 레논(John Lennon)이 90년대에 까지 살아 있었다면 이런 노래를 썼을 것"이라며 극찬했다.', 
'https://www.youtube.com/watch?v=iwy0OKM3-I4&list=RDiwy0OKM3-I4&start_radio=1', 
TO_DATE('2017-06-23', 'YYYY-MM-DD'), 
10);

-- 22번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
22, 
2, 
'Queen (퀸) - 베스트 앨범 1집 Greatest Hits I [2LP]', 
'/images/productimg/22.png', 
20, 
72900, 
'퀸의 대표곡을 총 망라한 베스트 앨범 [Greatest Hits] Vinyl 에디션 입고.
''Bohemian Rhapsody'' , ''Somebody To Love'' , ''We Will Rock You''등 총 17곡이 수록되어 있다.', 
'https://www.youtube.com/watch?v=XHrdsx8izBs&list=RDXHrdsx8izBs&start_radio=1', 
TO_DATE('2017-06-21', 'YYYY-MM-DD'), 
10);

-- 23번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
23, 
2, 
'Pink Floyd (핑크 플로이드) - The Dark Side Of The Moon [LP]', 
'/images/productimg/23.png', 
20, 
72300, 
'US 차트 1위, UK 차트 2위를 기록.
US 차트에서는 무려 741주간 연속 차트에 랭크되었고 또한 전 세계 토탈 세일즈 5천만장 이상의 판매고를 자랑하는 음악 역사상 최고의 명반으로 불리우는 앨범으로 발매 50주년을 기념하여 최신 리마스터반으로 재발매.', 
'https://www.youtube.com/watch?v=FEacDWPWfJU&list=RDFEacDWPWfJU&start_radio=1', 
TO_DATE('2023-10-25', 'YYYY-MM-DD'), 
10);

-- 24번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
24, 
2, 
'Liam Gallagher (리암 갤러거) - 1집 As You Were [조에트로프 컬러 LP]', 
'/images/productimg/24.png', 
20, 
76500, 
'이 시대 가장 위대한 로큰롤 스타의 완벽한 귀환!

전 세계가 사랑하는 오아시스의 프론트맨, 브릿팝의 아이콘 Liam Gallagher의 2017년첫 솔로 앨범. 브리티시 록의 정통을 계승하는 로큰롤! ‘Wall Of Glass’를 비롯하여 Oasis 시절을 재현하는 멜로디 ‘For What It''s Worth’. 
아름다운 사운드 속에서 울리는 서정성 ‘Chinatown’ 등이 수록. 
2025년 초도 한정으로 발매된 본 에디션은 회전시 에니메이션과 같이 움직이는 착시 효과를 경험할 수 있는 조이트로프(Zoetrope) LP로 제작되어 높은 소장가치를 전해준다.', 
'https://www.youtube.com/watch?v=zW1c1HyTHHQ&list=RDzW1c1HyTHHQ&start_radio=1', 
TO_DATE('2025-10-24', 'YYYY-MM-DD'), 
10);

-- 25번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
25, 
2, 
'Pink Floyd (핑크 플로이드) - Wish You Were Here [3LP]', 
'/images/productimg/25.png', 
20, 
158900, 
'1975년 발표와 동시에 미국과 영국에서 모두 차트 No. 1을 기록했던 앨범 [Wish You Were Here] 발매 50주년 기념반.
Pink Floyd 만의 시간, 뮤직 비즈니스, 부제에 관한 테마에 대한 철학을 엿볼 수 있는 앨범으로 발매 50주년을 기념하여 2CD, Blu-Ray Audio, Color Vinyl, 3LP Boxset을 비롯하여 CD+LP+BD+7"가 포함된 딜럭스 박스셋으로 발매.', 
'https://www.youtube.com/watch?v=Tu7oq3VNgpY&list=RDTu7oq3VNgpY&start_radio=1', 
TO_DATE('2025-12-17', 'YYYY-MM-DD'), 
10);

-- 26번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
26, 
2, 
'Oasis (오아시스) - 1집 Definitely Maybe [2LP]', 
'/images/productimg/26.png', 
20, 
121800, 
'올해로 데뷔 20주년을 맞이하는 오아시스가 그들의 살아있는 역사를 기념하기 위해 연속으로 리마스터 앨범을 발표할 것이라는 소식이 많은 팬들을 설레게하는 가운데 
그 첫번째로 1994년 발표된 명반 [Definitely Maybe]의 REMASTERED HEAVYWEIGHT DOUBLE VINYL! 기존 앨범에 포함 되지 않았던 ‘Sad Song’이 포함된 총 12곡의 Double Vinyl!', 
'https://www.youtube.com/watch?v=7BIfGnKoMok&list=RD7BIfGnKoMok&start_radio=1', 
TO_DATE('2014-05-26', 'YYYY-MM-DD'), 
10);

-- 27번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
27, 
2, 
'Iron Maiden (아이언 메이든) - Live After Death [옐로우 & 블루 컬러 2LP]', 
'/images/productimg/27.png', 
20, 
130200, 
'Iron Maiden의 메탈 역사상 가장 상징적인 라이브 앨범 중 하나인 ''Live After Death''를 발매 40주년을 기념하여 확장, 복각한 컬렉터스 에디션.
1985년에 발매되어 메탈 라이브의 교본으로 불리는 앨범으로 ''Aces High'' , ''The Trooper'' , ''Powerslave''등이 수록되어 있다.
(2015년 리마스터 음원 수록, 오리지널 아트 워크를 재현, 「World Slavery Tour」의 투어 프로그램의 레플리카외 투어 패스의 레플리카도 동봉)', 
'https://www.youtube.com/watch?v=Xg9aQvjMS60&list=RDXg9aQvjMS60&start_radio=1', 
TO_DATE('2025-12-24', 'YYYY-MM-DD'), 
10);

-- 28번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
28, 
2, 
'Oasis (오아시스) - (What''s The Story) Morning Glory? [2LP]', 
'/images/productimg/28.png', 
20, 
90100, 
'(What''s the Story) Morning Glory? is the second studio album by the English rock band Oasis, released on October 2, 1995 on Creation Records. It was produced by Owen Morris and the group''s guitarist Noel Gallagher. The structure and arrangement style of the album were a significant departure from the group''s previous record Definitely Maybe. Noel Gallagher''s compositions were more focused in balladry and placed more emphasis on "huge" choruses, with the string arrangements and more varied instrumentation on the record contrasting with the rawness of the group''s debut album.', 
'https://www.youtube.com/watch?v=1HceJD0XDXY&list=RD1HceJD0XDXY&start_radio=1', 
TO_DATE('2009-07-22', 'YYYY-MM-DD'), 
10);

-- 29번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
29, 
2, 
'Food Brain (푸드 브레인) - Social Gathering [LP]', 
'/images/productimg/29.png', 
20, 
50400, 
'기타리스트 첸 신키, 건반 연주자 야나기다 히로, 베이시스트 기무라 미치히로, 드러머 츠노다 히로 등 당시 일본 음악을 대표하는 연주자들이 모여 만들어낸 슈퍼 그룹의 화제가 되었던 Food Brain. 
이들이 ‘70년 남긴 유일한 앨범으로 일본록 음악의 역사를 열어나간 명작으로 여겨진다.', 
'https://www.youtube.com/watch?v=XCs_JjFQQjc&list=RDXCs_JjFQQjc&start_radio=1', 
TO_DATE('2025-12-09', 'YYYY-MM-DD'), 
10);

-- 30번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
30, 
2, 
'Pink Floyd (핑크 플로이드) - Wish You Were Here [컬러 LP]', 
'/images/productimg/30.png', 
20, 
60000, 
'1975년 발표와 동시에 미국과 영국에서 모두 차트 No. 1을 기록했던 앨범 [Wish You Were Here] 발매 50주년 기념반.
Pink Floyd 만의 시간, 뮤직 비즈니스, 부제에 관한 테마에 대한 철학을 엿볼 수 있는 앨범으로 발매 50주년을 기념하여 2CD, Blu-Ray Audio, Color Vinyl, 3LP Boxset을 비롯하여 CD+LP+BD+7"가 포함된 딜럭스 박스셋으로 발매.', 
'https://youtu.be/Tu7oq3VNgpY?list=RDTu7oq3VNgpY', 
TO_DATE('2025-12-17', 'YYYY-MM-DD'), 
10);

-- 31번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
31, 
2, 
'Alice in Chains (앨리스 인 체인스) - Jar of Flies [LP]', 
'/images/productimg/31.png', 
20, 
45900, 
'1994년에 발매된 ''Alice In Chains''의 EP 앨범 [Jar of Flies] Vinyl 리이슈반.
빌보드 200에서 1위를 기록한 앨범으로 어쿠스틱한 사운드가 특징적인 ''I Stay Away'' , ''No Excuses'' , ''Don''t Follow''등이 수록되어 있다.', 
'https://www.youtube.com/watch?v=LDOApsYhtrk&list=RDLDOApsYhtrk&start_radio=1', 
TO_DATE('2024-03-27', 'YYYY-MM-DD'), 
10);

-- 32번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
32, 
2, 
'Black Sabbath (블랙 사바스) - 16집 : Dehumanizer [2LP]', 
'/images/productimg/32.png', 
20, 
92500, 
'블랙 사바스의 1992년작 Dehumanizer는 로니 제임스 디오, 비니 어피스, 그리고 기저 버틀러가 오랜만에 함께한 작품으로, 오리지널 헤비 사운드와 디오 특유의 드라마틱한 보컬이 절묘하게 결합된 앨범이다. 1981년 Mob Rules 이후 이들의 첫 재결합 결과물로, 팬들 사이에서 높이 평가받는 디오-사바스 시기의 강렬한 귀환을 보여준다.

이번 디럭스 에디션은 리마스터된 오리지널 앨범과 함께 희귀 라이브 트랙, 웨인즈 월드 사운드트랙에 수록된 "Time Machine"의 독특한 버전 등을 수록한 보너스 디스크가 포함된 180g 중량반 2LP로 발매된다.', 
'https://www.youtube.com/watch?v=uzHm50QhKvo&list=RDuzHm50QhKvo&start_radio=1', 
TO_DATE('2025-05-09', 'YYYY-MM-DD'), 
10);

-- 33번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
33, 
2, 
'Radiohead (라디오헤드) - 7집 In Rainbows [LP]', 
'/images/productimg/33.png', 
20, 
58600, 
'OK Computer 이후 최고의 앨범으로 평가 받는 라디오헤드의 7번째 정규앨범 [In Rainbows].

서정적인 가사와 특유의 몽환적이고 관념적인 사운드의 결합으로 매혹적이고 동시에 자극적인 라디오헤드의 마스터피스가 될 이번앨범은 음악계 유수의 평론가들과 팬들로부터 극찬을 얻고있다.

라이브 공연에서 연주되어 열렬한 지지를 받았던 곡들이 대거 포함되어있는데 헤비한 리듬과 미니멀한 드러밍이 매력적인 "15 Steps", Paranoid Android 를 연상시키는 "Faust ARP", 2006년 투어에서 처음 선보이고 뜨거운 반응을 얻으며 결국 이번앨범의 싱글로 결정된 "Jigsaw Falling into Place" 와 또 하나의 베스트 트랙으로 손꼽히는 "Videotape" 까지 단 한 곡도 놓칠 수 없음이 자명하다.

거장다운 스포트라이트를 한 몸에 받으며 다시금 전세계 음악계 이슈의 중심에 서 있는 라디오헤드의 In Rainbows는 2007년 당신이 들어야 하는 단 한 장의 록 음반이 될 것이다.', 
'https://www.youtube.com/watch?v=9bahTUVLXZw&list=RD9bahTUVLXZw&start_radio=1', 
TO_DATE('2008-01-23', 'YYYY-MM-DD'), 
10);

-- 34번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
34, 
2, 
'Black Sabbath (블랙 사바스) - 14집 : Headless Cross[LP]', 
'/images/productimg/34.png', 
20, 
58000, 
'1989년 I.R.S. 레코드를 통해 발매된 블랙 사바스의 14번째 정규 앨범 Headless Cross는 오지 오스본과 디오의 그림자 속에서도 뚜렷한 개성을 드러낸 토니 마틴(Tony Martin) 보컬 시기의 대표작이다. 고딕한 분위기와 강력한 리프, 그리고 오컬트적인 가사로 무장한 이 앨범은 팬들과 평단 모두에게 깊은 인상을 남겼으며, 특히 유럽에서 큰 인기를 끌었다.

타이틀곡 “Headless Cross”를 비롯해, "Devil and Daughter", "Call of the Wild" 등의 싱글은 이 시기의 블랙 사바스가 얼마나 견고한 헤비 메탈 사운드를 유지하고 있었는지를 보여준다. 리드 기타리스트 토니 아이오미(Tony Iommi)의 불꽃 튀는 연주와, 전 Deep Purple 멤버 코지 파웰(Cozy Powell)의 드러밍이 더해져 중후하면서도 드라마틱한 사운드가 완성되었다.

이번 리이슈는 디지털 리마스터링을 통해 음질을 한층 업그레이드하였으며, 오리지널 아트워크와 함께 LP로 다시 태어났다.', 
'https://www.youtube.com/watch?v=gNeM014HDHc&list=RDgNeM014HDHc&start_radio=1', 
TO_DATE('2025-05-09', 'YYYY-MM-DD'), 
10);

-- 35번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
35, 
2, 
'Porcupine Tree (포큐파인 트리) - In Absentia [2LP]', 
'/images/productimg/35.png', 
20, 
92500, 
'스티븐 윌슨이 이끄는 프로그레시브 록 밴드 포큐파인 트리의 대표작이자 2000년대 초반 프로그/모던 록 사운드의 전환점을 이룬 기념비적인 앨범 《In Absentia》가 2021년 Transmission 레이블 리이슈 시리즈의 일환으로 2LP 게이트폴드 바이닐로 재발매되었다.

2002년에 발매된 《In Absentia》는 포큐파인 트리의 7번째 스튜디오 앨범이자, Deadwing, Fear of a Blank Planet과 함께 밴드의 전성기를 대표하는 3부작 중 첫 번째 앨범이다. 메탈, 프로그레시브 록, 앰비언트, 어쿠스틱 싱어송라이터 스타일이 절묘하게 융합된 이 앨범은 이후 수많은 밴드들이 따르게 된 새로운 사운드의 청사진을 제시하며, 이전 작품보다 3배 이상 판매고를 올리는 성과를 거뒀다.

"Trains", "The Sound of Muzak", "Blackest Eyes" 등 밴드의 대표곡들이 수록된 이 앨범은 공식적인 콘셉트 앨범은 아니지만, 현대 사회에 대한 시선, 연쇄 살인범과 상실된 순수함이라는 공통된 주제를 통해 스티븐 윌슨 특유의 다크하고 철학적인 세계관을 구축했다.', 
'https://www.youtube.com/watch?v=Nfql0PyA8D0&list=RDNfql0PyA8D0&start_radio=1', 
TO_DATE('2024-12-20', 'YYYY-MM-DD'), 
10);

-- 36번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
36, 
2, 
'Mazzy Star (매지스타) - So Tonight That I Might See [ 컬러 LP]', 
'/images/productimg/36.png', 
20, 
63600, 
'호프 산도발(보컬), 데이비드 로백(기타)로 구성된 아메리칸 얼터너티브 록밴드인 Mazzy Star가 1993년에 발표한 앨범 [So Tonight That I Might See].', 
'https://www.youtube.com/watch?v=yfzsBA5dZdE&list=RDyfzsBA5dZdE&start_radio=1', 
TO_DATE('2025-09-03', 'YYYY-MM-DD'), 
10);

-- 37번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
37, 
2, 
'Imagine Dragons (이매진 드래곤스) - Evolve [LP]', 
'/images/productimg/37.png', 
20, 
64100, 
'2015년 Smoke + Mirrors Tour어 시크릿 콘서트로 내한한 바 있는 아메리칸 얼터너티브 록 밴드 Imagine Dragons의 공식 3집 앨범 [Evolve]!

2012년 데뷔 앨범 [Night Visions]의 성공으로 곧바로 아메리칸 프리미엄 록 밴드로 성장한 이들은 록의 틀에서 벗어나 일렉트로닉, 힙합, 인디팝 등의 요소를 흡수하며 현재 미국을 대표하는 얼터너티브 록밴드로 사랑받고 있다.
2015년 2집 [Smoke + Mirrors]이후 2년만에 공개된 이번 신작은 라스베가스에 있는 팀 녹음실 Imagine Dragons Studio에서 팀 데뷔 때부터 함께해 온 Alex da Kid, Lorde의 신작에 참여한 Joel Little, 팝스타 Taylor Swift, Tove Lo, DNCE 등과 작업했던 스웨덴 프로듀서 듀오 Mattman & Robin등이 프로듀싱애 참여했다.
지난 2월 1일 디지털 싱글로 처음 공개되어 US 록 싱글차트 정상에 올랐던 ''Believer ''를 비롯해 4월 27일 두 번째 싱글로 발표되었던 ''Thunder''를 포함해 신곡 11곡을 담고 있다.', 
'https://www.youtube.com/watch?v=TGXlWQQthFg&list=RDTGXlWQQthFg&start_radio=1', 
TO_DATE('2017-07-28', 'YYYY-MM-DD'), 
10);

-- 38번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
38, 
2, 
'Dry Cleaning (드라이 클리닝) - 2집 Stumpwork [LP]', 
'/images/productimg/38.png', 
20, 
58600, 
'영국 혼성 록 그룹 Dry Cleaning의 새 앨범 [Stumpwork].

2021년 호평을 받은 [New Long Leg]에 이은 두번째 정규작으로 밴드는 이전 피치포크의 베스트 뉴 뮤직, 러프 트레이드의 올해의 앨범 1위, 그리고 영국 앨범 차트 4위를 차지하는 기록을 세웠다. 새로운 록스타일의 재해석과 재치가 돋보이는 앨범.', 
'https://www.youtube.com/watch?v=lYNwr7wuRHY&list=RDlYNwr7wuRHY&start_radio=1', 
TO_DATE('2022-11-09', 'YYYY-MM-DD'), 
10);

-- 39번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
39, 
2, 
'Billie Eilish(빌리아일리시)-WHEN WE ALL FALL ASLEEP,WHERE DO WE GO?[페일 옐로우 컬러LP]', 
'/images/productimg/39.png', 
20, 
59300, 
'사운드 클라우드를 통해 처음 발표한 ''Ocean Eyes''가 스포티파이 바이럴 차트 1위를 차지하고, 애플 뮤직, 베보 (VEVO) 등 음악 전문 미디어가 주목하는 신인으로 꼽는 등 데뷔 초부터 팝 씬에서 큰 기대를 받아온 Billie Eilish가 드디어 그녀의 첫 정규 앨범을 발표한다. 빌보드 얼터너티브 앨범 차트 1위를 차지한 데뷔 EP 앨범 [Don''t Smile At Me]와 싱글 ''You Should See Me In A Crown'', ''When The Party''s Over'', 그리고 애플 광고 음악으로 사용되어 사랑을 받은 ''Come Out And Play'' 등 꾸준한 활동을 통해 보여준 그녀만의 독보적인 분위기와 몽환적인 사운드는 매니아 팬층을 넘어 팝 음악을 즐기는 대중들의 마음까지 사로잡았다.', 
'https://www.youtube.com/watch?v=XJBUWZsT38c&list=PLMSmPqvJ6siJwH_c2H_N8j9JqDt8ogyny', 
TO_DATE('2019-04-04', 'YYYY-MM-DD'), 
10);

-- 40번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
40, 
2, 
'ink Floyd (핑크 플로이드) - The Wall [2LP]', 
'/images/productimg/40.png', 
20, 
68800, 
'영국의 프로그레시브 록 그룹 Pink Floyd의 역사적인 명반으로 불리우는 [The Wall] Vinyl 리이슈반!
음악 역사상 가장 성공적인 컨셉트 앨범 중의 하나로 멤버 Roger Waters의 인간의 소외와 암울한 현대상, 개인의 고립이라는 주제에 관한 록 오페라라고 할 수 있다. Gerald Scarfe의 유니크한 아트웍이 돋보이는 이 앨범에는 미국과 영국 차트에서 모두 1위를 차지하기도 한 ''Another Brick In The Wall Pt2.'' 가 수록되어 있다.', 
'https://www.youtube.com/watch?v=uzsEmI61Xas&list=RDuzsEmI61Xas&start_radio=1', 
TO_DATE('2016-11-09', 'YYYY-MM-DD'), 
10);

-- 41번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
41, 
3, 
'크리스마스 재즈 캐럴 모음집 (Christmas Jazz) [투명 레드 컬러 LP]', 
'/images/productimg/41.png', 
20, 
58600, 
'재즈 황금시대의 크리스마스 Jazz Carol 17 컬렉션
23인의 유럽화가들의 25컷 크리스마스 삽화수록
1LP 게이트폴더 + 아트북 (305*305)

180g Audiophile Vinyl
Limited Deluxe Edition
투명레드컬러 1000장 한정판

재즈 황금시대의 크리스마스 Jazz Carol 17 컬렉션

냇킹콜, 프랑크 시나트라, 멜 토메, 빙 크리스비, 펫 분, 엘비스 프레슬리 등 따뜻한 중저음의 캐롤을 시작으로 엘라 피츠제럴드, 줄리 런던, 어사 키트, 마할리아 잭슨 등 캐롤의 여왕들이 노래한 재즈 캐롤을 모두 담았다. 이 앨범은 20세기를 풍미한 재즈 황금시대를 빛낸 전설들의 크리스마스 음악이다.', 
'https://www.youtube.com/watch?v=wKhRnZZ0cJI&list=RDwKhRnZZ0cJI&start_radio=1', 
TO_DATE('2025-11-05', 'YYYY-MM-DD'), 
10);

-- 42번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
42, 
3, 
'찰리 브라운 크리스마스 음악 [Zoetrop 컬러 LP]', 
'/images/productimg/42.png', 
20, 
47700, 
'Vince Guaraldi Trio - A Charlie Brown Christmas (60th Anniversary) [180g Zoetrope Picture Disc LP]
세대를 넘어 사랑받는 크리스마스 재즈 명반, 60주년 기념 한정판!

세계에서 가장 사랑받는 홀리데이 앨범 중 하나,
Vince Guaraldi Trio의 A Charlie Brown Christmas가 발매 60주년을 기념해
처음으로 180g 조이트로프(Zoetrope) 픽처 디스크 LP로 출시된다.

이번 특별 에디션은 PEANUTS 탄생 75주년과 애니메이션 A Charlie Brown Christmas 방영 60주년을 기념하며,
LP 양면에 피너츠 크리스마스 스페셜의 명장면을 담은 조이트로프 아트웍이 새겨져 소장 가치를 한층 높였다.

재즈 피아니스트 빈스 과랄디(Vince Guaraldi)가 이끄는 트리오의 연주로 완성된 본작은
“Christmas Time Is Here”, “O Tannenbaum”, “Linus and Lucy” 등
지금도 매년 크리스마스를 대표하는 곡들로 가득 차 있으며,
세대를 넘어 어린이와 어른 모두에게 재즈의 즐거움을 알려주는 불멸의 클래식이다.', 
'https://www.youtube.com/watch?v=_fh133ZO1AE&list=RD_fh133ZO1AE&start_radio=1', 
TO_DATE('2025-12-16', 'YYYY-MM-DD'), 
10);

-- 43번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
43, 
3, 
'Miles Davis (마일즈 데이비스) - Kind Of Blue [LP]', 
'/images/productimg/43.png', 
20, 
38800, 
'재즈 역사상 가장 많이 팔린 앨범! 레코드 뮤직사에 길히 남을 이정표!
마일즈 데이비스의 대표작 [Kind Of Blue] Legacy Vinyl 리이슈반!
존 콜트레인, 빌 에반스, 캐논볼 애덜리, 지미 콥, 폴 탬버스, 윈튼 캘리의 스텔라 라인업!
온갖 수식어로도 그 부족한 공허함을 채울 길 없는 걸작 [Kind Of Blue]가 오리지널 아트웤과 180그램 중량반 오디오 파일 바이닐 버전으로 재탄생!', 
'https://www.youtube.com/watch?v=ylXk1LBvIqU&list=RDylXk1LBvIqU&start_radio=1', 
TO_DATE('2015-11-10', 'YYYY-MM-DD'), 
10);

-- 44번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
44, 
3, 
'Chet Baker (쳇 베이커) - Sings [LP]', 
'/images/productimg/44.png', 
20, 
40700, 
'익숙한 모노의 밀도, 그 위에 펼쳐진 무대. 쳇 베이커 - Sings, 섬세한 스테레오 마스터와 최고의 커팅과 프레싱으로 더 넓고 더 맑아졌다.

‘Sings’의 Primus Records의 에디션은 보컬과 트럼펫이 호흡이 들리는 거리로 한 발 뒤로 물러나 자연스러운 공간감과 악기 분리를 드러낸 스테레오 마스터, ‘SST 커팅 180g 프레싱으로 부드러운 공기감, 안정된 이미징, 한층 명료한 목소리와 트럼펫, 베이스의 윤기를 살려냈습니다.

「My Funny Valentine」, 「I Fall in Love Too Easily」 등 불멸의 스탠더드가 한 장의 LP에!', 
'https://www.youtube.com/watch?v=-1Lchlw0GbI&list=RD-1Lchlw0GbI&start_radio=1', 
TO_DATE('2015-11-06', 'YYYY-MM-DD'), 
10);



select *
From tbl_product;

commit;




-- 45번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
45, 
3, 
'Laufey (라이베이) - Bewitched [The Goddess Edition] [블루 컬러 2LP]', 
'/images/productimg/45.png', 
20, 
69000, 
'레이베이 [비위치드 - 더 가디스 에디션]
LAUFEY [Bewitched - The Goddess Edition] 2LP 박스/블루 컬러 바이닐, 부클릿, 보드게임

2022년에 선보인 앨범 [Everything I Know About Love]를 통해 극찬을 받으며 현재 세계에서 가장 주목받고 있는 싱어송라이터로 여겨지는 레이베이. 바이올린 연주자인 어머니와 아이슬란드 출신 재즈 애호가인 아버지 사이에서 태어나 첼리스트이자 싱어송라이터로 성장한 그녀의 음악은 상쾌하면서 깊은 감정을 담아낸다.
2023년에 선보인 그녀의 새 앨범에는 "사랑"을 테마로 만들어낸 전작보다 더욱 성숙해진 사운드와 노래가 담겨있다. 현악을 가미한 부드러운 사운드에 완벽하게 조화되는 그녀의 로맨틱한 음성으로 전하는 타이틀 곡 ''Bewitched'', 아델의 대히트작 ''Someone Like You''의 프로듀서인 댄 윌슨이 참여한 ''Promise'' 등 최고의 노래들을 만날 수 있다.', 
'https://www.youtube.com/watch?v=AI29dHDkJh4&list=RDAI29dHDkJh4&start_radio=1', 
TO_DATE('2024-06-19', 'YYYY-MM-DD'), 
10);

-- 46번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
46, 
3, 
'Bill Evans (빌 에반스) - Portrait in Jazz [투명 그린 컬러 LP]', 
'/images/productimg/46.png', 
20, 
30600, 
'빌 에반스와 베이시스트 스콧 라파로(Scott Lafaro)가 처음으로 함께 녹음한 LP로, 투명 그린 컬러반으로 재발매되었다.

* 올뮤직 평점: 5/5
* 다운비트 평점: 5/5

* 왁스타임의 컬러반 시리즈, Wax Time In Color 앨범
* 투명 그린 컬러반
* 180 gram audiophile vinyl, Limited Edition', 
'https://www.youtube.com/watch?v=YuuFffOrpGU&list=RDYuuFffOrpGU&start_radio=1', 
TO_DATE('2018-03-14', 'YYYY-MM-DD'), 
10);

-- 47번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
47, 
3, 
'Jimmy Smith (지미 스미스) - House Party [LP]', 
'/images/productimg/47.png', 
20, 
37200, 
'블루노트 창립 80주년을 기념하여 새롭게 런칭한 ‘Blue Note The Classic Vinyl’ 시리즈로 오리지널 마스터 테이프 마스터링으로 제작한 180g 중량반으로 제작 뛰어난 음질을 자랑하며 오리지널 초반과 동일한 커버 디자인으로 높은 소장가치를 전해준다.
모던재즈의 시대를 대표하였던 최고의 하몬드 올갠 연주자 Jimmy Smith의 ‘58년 작품. Lee Morgan(트럼펫), Curtis Fuller(트롬본), George Coleman(알토색소폰) 등 다양한 혼 세션들이 참여 한층 풍성하여 다이내믹한 사운드를 담고 있다. 15분이 넘는 대곡으로 재현한 챨리 파커의 고전 ‘Au Privave’을 비롯하여 블루지한 해석이 돋보이는 케니 버렐의 작품 ‘Blues After All’ 등의 작품이 수록. ', 
'https://www.youtube.com/watch?v=vuSLKFaPk04&list=RDvuSLKFaPk04&t=1s', 
TO_DATE('2025-12-10', 'YYYY-MM-DD'), 
10);

-- 48번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
48, 
3, 
'보사노바 풍의 재즈 모음집 [재즈 브라질] (Jazz Brazil) [LP]', 
'/images/productimg/48.png', 
20, 
31900, 
'180 gram audiophile vinyl
게이트폴드 슬리브

보사노바풍의 재즈곡 16곡 수록한 앨범.
스탄 게츠, 디지 길레스피, 찰리 버드, 콜맨 호킨스, 대표적인 보사노바 아티스트인 안토니오 카를로스 조빔, 주앙 질베르토의 곡들이 포함되어 있다.', 
'https://www.youtube.com/watch?v=RDWnMy9Cq-E&list=RDRDWnMy9Cq-E&start_radio=1', 
TO_DATE('2019-01-18', 'YYYY-MM-DD'), 
10);

-- 49번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
49, 
3, 
'Laufey (라이베이) - Typical of Me [LP]', 
'/images/productimg/49.png', 
20, 
33800, 
'세계적인 주목을 받고 있는 싱어송라이터 레이베이!
재즈와 보사노바를 넘나드는 편안한 노래들을 만날 수 있는 그녀의 데뷔 EP!

2022년에 선보인 앨범 [Everything I Know About Love]를 통해 극찬을 받으며 현재 세계에서 가장 주목받고 있는 싱어송라이터로 여겨지는 레이베이.
바이올린 연주자인 어머니와 아이슬란드 출신 재즈 애호가인 아버지 사이에서 태어나 첼리스트이자 싱어송라이터로 성장한 그녀의 음악은 상쾌하면서 깊은 감정을 담아낸다.

이 작품은 원래 2021년에 선보인 그녀의 데뷔 EP로 Spotify에서 화제가 되며 차트 1위를 차지한 아이슬란드 라디오 히트곡 ‘Street by Street’와 ‘I Wish You Love’ 등 재즈와 보사노바를 넘나드는 아름다운 노래들이 담겨있다.
풍성한 보컬로 전하는 최고의 명곡들을 만날 수 있다.', 
'https://www.youtube.com/watch?v=Xsn8fIqhk9w&list=RDXsn8fIqhk9w&start_radio=1', 
TO_DATE('2024-04-23', 'YYYY-MM-DD'), 
10);

-- 50번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
50, 
3, 
'Laufey (라이베이) - A Matter Of Time [타임리스 블루 컬러 LP + 7인치 Vinyl]', 
'/images/productimg/50.png', 
20, 
49400, 
'전작으로 그래미를 수상한 바 있는 싱어송라이터 레이베이!
전세계적인 주목을 받아온 그녀의 부드러운 노래들을 담은 2025년 앨범!

레이베이 [어 매터 오브 타임]
LAUFEY [A Matter Of Time]

지난 앨범 [Bewitched]로 그래미 [베스트 트래디셔널 팝] 부문을 수상하며 현재 세계에서 가장 주목받고 있는 싱어송라이터로 여겨지는 레이베이. 바이올린 연주자인 어머니와 아이슬란드 출신 재즈 애호가인 아버지 사이에서 태어나 첼리스트이자 싱어송라이터로 성장한 그녀의 음악은 상쾌하면서 깊은 감정을 담아낸다.

2025년에 선보이는 그녀의 신작에는 고전적 재즈 감성과 현대적 팝 감성을 절묘하게 결합한 섬세한 사운드와 노래가 담겨있다. 시간과 사랑, 성장에 대한 사색을 담은 자작곡들을 부드러운 스트링과 감미로운 보컬이 조화로 전한다. 전세계적인 주목을 받고 있는 그녀의 음악적 진화를 즐길 수 있는 작품이다.', 
'https://www.youtube.com/watch?v=MGO1Um9L1hY&list=RDMGO1Um9L1hY&start_radio=1', 
TO_DATE('2025-08-22', 'YYYY-MM-DD'), 
10);

-- 51번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
51, 
3, 
'Bill Evans Trio (빌 에반스 트리오) - Waltz For Debby [투명 퍼플 컬러 LP]', 
'/images/productimg/51.png', 
20, 
30600, 
'* 180 gram audiophile vinyl
* 투명 퍼플 컬러반
* 한정반
1 Bonus Track 추가 수록

BILL EVANS, piano
SCOTT LaFARO, bass
PAUL MOTIAN, drums

Live at the Village Vanguard, New York, June 25, 1961', 
'https://www.youtube.com/watch?v=EpVXH3Vm2wg&list=RDEpVXH3Vm2wg&start_radio=1', 
TO_DATE('2018-05-14', 'YYYY-MM-DD'), 
10);

-- 52번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
52, 
3, 
'Duke Jordan (듀크 조단) - Flight To Denmark [LP]', 
'/images/productimg/52.png', 
20, 
43500, 
'국내 최장기 재즈 베스트 셀러! 재즈 피아니스트 듀크 조단의 최고 역작!
2014년 새롭게 리마스터링을 거친 향상된 음질과 180g 오디오파일용 중량반 LP로 제작!
Duke Jordan / Flight To Denmark (180g 오디오파일 LP)

국내 최장기 재즈 베스트 셀러! 재즈 피아니스트 듀크 조단의 최고 역작!
2014년 새롭게 리마스터링을 거친 향상된 음질과 180g 오디오파일용 중량반 LP로 제작! (초도한정, Limited Edition)

하얀 설원 위에 서있는 중년 신사의 고독한 이미지 만큼이나 아름답고 순수한 재즈가 담겨진 재즈 피아니스트 듀크 조단의 73년 명작. 미국에서의 활동을 접고 유럽으로 건너가 비로서 자신의 내재된 아름다움을 토해냈던 듀크 조단은 특유의 서정미와 동화같은 순수함을 내세운 본 작품을 통하여 지금까지 많은 재즈팬들에게 큰 호응을 얻은 바 있다.

인상적인 인트로와 멜로딕한 진행으로 국내에서 절대적인 사랑을 받고 있는 명곡 ‘No Problem’을 비롯하여 그의 서정적인 피아니즘이 빛을 발하는 ‘How Deep Is The Ocean?’, 그리고 뛰어난 스윙감이 인상적인 ‘On Green Dolphin Street’ 등 얼마만큼이나 재즈가 아름다울 수 있는가를 가장 직접적으로 보여주고 있는 맑고 순수한 작품!! (스윙저널 골드디스크 수상)', 
'https://www.youtube.com/watch?v=UKrAXUcJXHo&list=RDUKrAXUcJXHo&start_radio=1', 
TO_DATE('2014-11-25', 'YYYY-MM-DD'), 
10);

-- 53번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
53, 
3, 
'Keith Jarrett (키스 자렛) - The Melody At Night, With You [LP]', 
'/images/productimg/53.png', 
20, 
35100, 
'수많은 명연을 통해 현대 재즈를 대표하는 피아니스트로 자리매김하고 있는 키스 재럿.
이 작품은 동양적인 선(禪) 사상에 몰두하기 시작한 키스 재럿이 최고의 평온 속에서 연주한 발라드 연주의 명연을 담았다.
자신의 집에서 녹음된 이 독주집은 정중동의 이미지를 서양적인 관점에서 접근한 새로운 아름다움을 가득 담고 있다.
가장 개인적이고 주관적이면서도 폭넓은 감동을 선사할 수 있는 이 앨범은 들으면 들을수록 그 깊이를 느끼게 하는 또 하나의 문제작.', 
'https://www.youtube.com/watch?v=KfMnCCtA_Ww&list=RDKfMnCCtA_Ww&start_radio=1', 
TO_DATE('2019-08-02', 'YYYY-MM-DD'), 
10);

-- 54번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
54, 
3, 
'재즈 명연 모음집 (Take Five - Great Jazz Instrumentals) [LP]', 
'/images/productimg/54.png', 
20, 
49200, 
'최고의 재즈 스탠다드 명곡으로만 구성된 베스트 컴필레이션 앨범 [Take Five - Great Jazz Instrumentals]가 LP로도 발매된다. 데이브 브루벡의 ''Take Five'', 마일즈 데이비스의 ''My Funny Valentine'', 그리고 존 콜트레인의 ''My Favorite Things'' 등이 수록되어 있다.', 
'https://www.youtube.com/watch?v=-DHuW1h1wHw&list=RD-DHuW1h1wHw&start_radio=1', 
TO_DATE('2017-10-16', 'YYYY-MM-DD'), 
10);

-- 55번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
55, 
3, 
'Keith Jarrett - The Koln Concert 키스 자렛 쾰른 콘서트 [2LP]', 
'/images/productimg/55.png', 
20, 
52000, 
'전세계적으로 키스 재럿의 음악적 위치를 확고히 다진 계기가 된 현대 재즈 최고의 명작 중 하나. 독일 쾰른에서의 독주 공연 실황을 담고 있는 이 아름다운 앨범은 그 어떤 레코드 콜렉션에서도 절대로 빠질 수 없는 필수목록으로 지난 20여 년 동안 굳건한 자리를 지키고 있다. 무수한 찬사와 함께 재즈 이외에도 많은 장르의 음악에게 절대적인 영향을 남겼다.', 
'https://www.youtube.com/watch?v=Pd_Kti6jvy8&list=RDPd_Kti6jvy8&start_radio=1', 
TO_DATE('2010-07-12', 'YYYY-MM-DD'), 
10);

-- 56번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
56, 
3, 
'Chet Baker (쳇 베이커) - I Fall In Love Too Easily [LP]', 
'/images/productimg/56.png', 
20, 
26000, 
'쳇 베이커 [아이 폴 인 러브 투 이질리]
CHET BAKER [I FALL IN LOVE TOO EASILY] 1LP 게이트폴드 커버

트럼펫 연주자이자 싱어 쳇 베이커는 우수 어린 연주와 노래로 재즈 역사상 가장 인기를 얻었던 뮤지션 중 한 명으로 여겨진다. WAGRAM의 뮤직 레전드 시리즈로 선보이는 이 작품은 1954년에서 1962년까지 녹음된 베이커의 다양한 명곡들을 담았다. ‘My Funny Valentine’에서 ‘I Fall In Love Too Easily’. But Not For Me’에 이는 베이커의 탁월한 노래와 연주를 만날 수 있다.', 
'https://www.youtube.com/watch?v=QwAwtMt8t4s&list=RDQwAwtMt8t4s&start_radio=1', 
TO_DATE('2024-04-30', 'YYYY-MM-DD'), 
10);

-- 57번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
57, 
3, 
'Johnny Griffin (조니 그리핀) - A Blowing Session [LP]', 
'/images/productimg/57.png', 
20, 
37200, 
'블루노트 창립 80주년을 기념하여 새롭게 런칭한 ‘Blue Note The Classic Vinyl’ 시리즈로 오리지널 마스터 테이프 마스터링으로 제작한 180g 중량반으로 제작 뛰어난 음질을 자랑하며 오리지널 초반과 동일한 커버 디자인으로 높은 소장가치를 전해준다.
테너 색소폰 연주자 Johnny Griffin의 ‘57년 작품으로 그와 더불어 Hank Mobley, John Coltrane 이렇게 세명의 테너 거장들 그리고 Lee Morgan(트럼펫), Wynton Kelly(피아노), Paul Chambers(베이스), Art Blakey(드럼) 등 당대 최고의 세션들이 참여하여 화제가 되었던 앨범. 화려한 테크닉과 전투적인 앙상블이 돋보이는 ‘The Way You Look Tonight를 비롯하여 ‘All the Things You Are’ 등의 고전들이 수록된 그의 최고작.
', 
'https://www.youtube.com/watch?v=_9Qaxx6vxyo&list=RD_9Qaxx6vxyo&start_radio=1', 
TO_DATE('2025-12-10', 'YYYY-MM-DD'), 
10);

-- 58번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
58, 
3, 
'Chet Baker & Bill Evans (쳇 베이커, 빌 에반스) - Alone Together [레드 컬러 LP]', 
'/images/productimg/58.png', 
20, 
30600, 
'180 gram audiophile vinyl

1 Bonus Track

1958년부터 1959년에 있었던 쳇 베이커와 빌 에반스의 공연 세션. 페퍼 아담스와 케니 버렐 등이 참가한 리버사이드 레이블의 명반이다.', 
'https://www.youtube.com/watch?v=zdDhinO58ss&list=RDzdDhinO58ss&start_radio=1', 
TO_DATE('2019-04-26', 'YYYY-MM-DD'), 
10);

-- 59번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
59, 
3, 
'Moon / Tsuyoshi Yamamoto (문혜원 with 츠요시 야마모토) - Fascination [LP]', 
'/images/productimg/59.png', 
20, 
71500, 
'Moon(혜원), 츠요시 야마모토

K-Jazz를 대표하는 보컬리스트 Moon(혜원),
일본의 전설적인 재즈 피아니스트 츠요시 야마모토와의 세 번째 협연 앨범 [Fascination] 발매!

2024년 발매한 첫 협업 앨범 [Midnight Sun]으로 일본 ‘재즈 오디오 디스크 어워즈’에서 ‘베스트 보컬 앨범’을 수상하며 평단과 대중에게 모두에게 호평을 받았던 Moon(혜원)과 츠요시 야마모토가 세 번째 협업 앨범 [Fascination]으로 돌아왔다.

이번 앨범에는 Moon(혜원)의 오리지널 곡 ''Fascination’을 비롯하여 ''Alfie'', ''Mood Indigo''와 같은 감미로운 발라드 등 다채로운 매력의 재즈 스탠다드 명곡들이 수록되었다. 또한 한국 1세대 레전드 재즈 보컬리스트 박성연의 대표곡 ''물안개''에 Moon(혜원)이 직접 영어 가사를 붙여 새롭게 재해석한 버전을 담아 특별함을 더했다. LP버전에는 디지털 및 CD버전에는 포함되지 않은 스페셜 트랙 ’Midnight Sun Will Never Set’이 수록되었다.', 
'https://www.youtube.com/watch?v=a6Y_YWuiQz8&list=RDa6Y_YWuiQz8&start_radio=1', 
TO_DATE('2025-10-16', 'YYYY-MM-DD'), 
10);

-- 60번 제품
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
60, 
3, 
'Archie Shepp (아치 셉) - Four for Trane [LP]', 
'/images/productimg/60.png', 
20, 
37200, 
'2025년 최근 새롭게 런칭한 Verve Vault Series로 Verve 레이블의 대표적인 명반들을 새롭게 발굴 레코딩씬의 거물급 엔지니어 Ryan K. Smith 오리지널 아날로그 마스터 테잎 마스터링을 담당하였으며 Optimal Pressings 의 180g LP로 제작 오디오파일급 사운드를 들려준다.
‘60년대 이후 프리재즈와 에스닉 재즈를 넘나드는 탁월한 음악성으로 사랑받았던 테너 색소폰 연주자 Archie Shepp의 ‘65년 작품. Alan Shorter(프루겔혼), John Tchicai(알토 색소폰), Roswell Rudd(트롬본) 이렇게 4명의 혼 연주자와 함께 존 콜트레인의 작품을 연주한 이색작으로 이국적인 향취를 강하게 느낄수 있는 ‘Syeeda''s Song Flute’를 비롯하여 네 뮤지션의 뜨거운 앙상블을 들려주는 ‘Naima’ 등의 작품이 수록되어 있다.', 
'https://www.youtube.com/watch?v=hnkM9mD1C_Q&list=RDhnkM9mD1C_Q&start_radio=1', 
TO_DATE('2025-12-10', 'YYYY-MM-DD'), 
10);

COMMIT;





SET DEFINE OFF;

-- 61번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
61, 
4, 
'임윤찬 - 바흐: 골드베르크 변주곡 (Bach: Goldberg Variations) [2LP]', 
'/images/productimg/61.png', 
20, 
66500, 
'수 개월 전부터 매진이 되었던 2025년 4월 25일 카네기홀의 실황을 담은 앨범.
무려 <골드베르크 변주곡>이다.
데카 레이블은 이 연주를 음반으로 담으면서,
70년 전 바로 근처에서 22살의 글렌 굴드가 녹음한 전설적인 <골드베르크> 앨범을 떠올렸고, 차세대의 새로운 표준이 될 것임을 확신했다.

<뉴욕 타임즈>는 이 연주에 대해 다음과 같이 평했다.
"연주가 진행되는 동안 더욱 깊어지는 연주에 대해, 임윤찬이 이 곡에 스며들었기 때문이라고 생각했다.
하지만, 그 후 바흐의 여정을, 한 젊은이가 성숙해가는 과정의 이야기로 바꾸려는 임윤찬의 의도, 적어도 본능이 있었는지 생각하게 되었다."
이런 평은 임윤찬의 전작, 차이코프스키의 <사계> 해석을 떠오르게 한다.
이 곡 역시, 임윤찬의 연주는 한 사람의 삶의 여정을 그리고 있기 때문이다.

임윤찬은 바흐의 이 위대한 곡에 대해, "저에게, 이 곡은 음악을 통해 들려주는 삶의 여정입니다. 존재 자체에 대한 바흐의 묘사이며, 이런 곡을 연주하는 것이, 제가 음악을 하는 이유입니다."라고 밝혔다.', 
'https://www.youtube.com/watch?v=seYfmj3L2EA&list=RDseYfmj3L2EA&start_radio=1', 
TO_DATE('2025-02-06', 'YYYY-MM-DD'), 
10);

-- 62번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
62, 
4, 
'임윤찬 - 차이콥스키: 사계 (Tchaikovsky: The Seasons, Op. 37a) [LP]', 
'/images/productimg/62.png', 
20, 
57400, 
'임윤찬이 오랫동안 공을 들였던 작품 차이코프스키 <사계>가 발매된다. 이 작품에 대해 임윤찬은 삶의 마지막 1년으로 해석하며, 앨범 안에는 작품이 그리는 12개의 달에 대해 임윤찬이 직접 쓴 글이 수록되어 있다.

예를 들어, 1월 화롯가에서''에 대해, 그는 "과거에 대한 생각에 잠긴 한 남자가 이유 없이 슬픔을 느끼면서 시작되지만, 새로운 경험은 희망을 가져다 준다. 격한 감정의 흐느낌은 담배 연기가 휘감기는 백일몽에 자리를 내준다.
그는 울다가 잊혀진 기억에 빠져 과거의 문턱에서 끊임없이 망설인다. 하지만 그는 현재로 돌아와 모든 것을 받아들이고, 종소리가 울리면서 다시는 오지 않을 날을 마감한다.', 
'https://www.youtube.com/watch?v=CFAwQyNdoVQ&list=RDCFAwQyNdoVQ&start_radio=1', 
TO_DATE('2025-08-29', 'YYYY-MM-DD'), 
10);

-- 63번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
63, 
4, 
'조성진 - 라벨: 피아노 협주곡 (Ravel: The Piano Concertos) [LP]', 
'/images/productimg/63.png', 
20, 
52800, 
'언제 나올 것인지 기다렸던 조성진의 라벨 피아노 협주곡 LP! 지난 2월 발매된 CD는 여러 번 품절이 될 정도로 많은 인기를 끌었다. 많은 팬들이 기다렸던 LP 버전이 드디어 발매되어 또 하나의 베스트셀러 반열에 오를 것으로 기대된다.', 
'https://www.youtube.com/watch?v=qBKnNdWqNJM&list=RDqBKnNdWqNJM&start_radio=1', 
TO_DATE('2025-06-26', 'YYYY-MM-DD'), 
10);

-- 64번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
64, 
4, 
'Enrico Mainardi 바흐: 무반주 첼로 모음곡 전곡 (Bach: Cello Suites BWV 1007?1012) [4LP]', 
'/images/productimg/64.png', 
20, 
159300, 
'바흐 무반주 첼로 모음곡은 수많은 명연을 낳았지만, 엔리코 마이나르디(1897-1976) 의 해석은 별도의 좌표에 놓인다. 화려한 감정보다 구조·호흡·여백을 앞세워, 한 대의 첼로에서 폴리포니(다성) 를 드러내는 접근. 본 박스는 그가 독일 Eurodisc에서 남긴 1963-64년 스테레오 녹음을 담은 4LP 세트로, 마이나르디가 남긴 유일한 스테레오 전곡 녹음이라는 점에서 역사적, 음악적 의의가 크다.

느린 템포와 최소한의 비브라토, 레가토-데타셰의 치밀한 배합, 긴 호흡의 프레이징을 통해 선율 사이 침묵의 의미까지 음악으로 만든 해석. 사운드는 스테레오 특유의 공간감과 입체감으로 첼로의 미세한 결을 포착하며, 오늘 들어도 한층 건축적인 투명함과 영적인 고요가 살아난다. 북릿에는 새로운 해설과 더불어, 녹음 직후의 인터뷰 전문(그가 음악을 대하는 태도와 해석 철학)이 실려 있어 감상의 깊이를 더한다.
', 
'https://www.youtube.com/watch?v=Lg58HTdRjbQ&list=RDLg58HTdRjbQ&start_radio=1', 
TO_DATE('2025-01-15', 'YYYY-MM-DD'), 
10);

-- 65번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
65, 
4, 
'클래식 피아니스트가 들려주는 지브리 명곡집 [블루 컬러 LP]', 
'/images/productimg/65.png', 
20, 
67000, 
'음악이 하늘을 가르며 울려 퍼지는 지브리의 세계로 여행을 떠나보세요. ‘Piano in the Sky(하늘의 피아노)’는 눈을 뜨고 꿈꾸는 듯한 특별한 감각적 경험을 선사한다
히사이시 조의 음악과 미야자키 하야오의 매혹적인 세계관에서 영감을 받은 기욤 마송은 하늘과 구름 사이를 유유히 떠도는 음표들이 시와 순수한 감정을 뒤섞는 공중 발레 속으로 여러분을 안내한다.
기욤 마송 (피아노/편곡)

"스튜디오 지브리의 영화는 상징주의, 몽환적 분위기, 그리고 시각적 아름다움을 표현하며 관객에게 독특하고 마법 같은 경험을 선사합니다. 이 모든 본질은 프랑스 인상파 작곡가, 전통적인 동양적 선율, 그리고 현대 대중문화에서 영감을 받은 음악 언어를 만들어낸 작곡가 히사이시 조의 음악을 통해 생생하게 구현되어, 지난 수십 년간 가장 아름답고 시적인 영화 음악을 탄생시켰습니다.

이 앨범의 피아니스트로서 저는 가장 부드러운 음색부터 가장 강렬한 주제곡까지 원곡의 모든 음악적 디테일을 담아내고자 했으며, 오케스트라의 풍부한 음색을 온전히 보존하고자 노력했습니다. 피아노의 풍부한 표현력을 통해, 저는 히사이시 조의 작품에 최대한 충실하고, 작품의 감정과 정신을 보존하면서 동시에 새롭고도 친숙한 피아노 솔로 감상 경험을 선사하고자 했습니다. 이러한 모든 이유로, 이 작품을 녹음할 수 있는 기회에 진심으로 감사하며, 그 결과물을 이 앨범에 공유하게 되어 기쁩니다."', 
'https://www.youtube.com/watch?v=i8wV2cv1Rz4&list=RDi8wV2cv1Rz4&start_radio=1', 
TO_DATE('2025-11-26', 'YYYY-MM-DD'), 
10);

-- 66번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
66, 
4, 
'힐러리 한 바이올린 연주 모음집 (Hilary Hahn: Paris) [2LP]', 
'/images/productimg/66.png', 
20, 
61700, 
'잠시 DECCA에 들려 바흐 무반주 녹음을 완성한 힐러리 한이 다시 DG로 돌아와 "파리"의 문화적 풍부함을 상징하는 음반을 발매 한다.

지휘자 미코 프랑크와 함께 핀란드 작곡가 에이노유하니 라우타바라의 바이올린 협주곡을 연주했던 힐러리 한은 라디오 프랑스 필하모니 상주 연주자 활동을 준비하면서 라우타바라에게 두번째 바이올린 협주곡을 제안하게 된다.
하지만 2016년 작곡가가 세상을 떠나면서 멀어지는 듯 했던 계획은 그의 아내를 통해 전해 받은 바이올린과 오케스트라를 위한 작품의 미완성 악보를 통해 그 꿈이 실현 된다.
라우타바라의 제자인 칼레비 아호가 오케스트라 파트를 완성한 [2개의 세레나데]가 바로 그것으로, 쇼숑의 [시곡]과 파리에서 초연된 프로코피에프의 바이올린 협주곡 1번과 함께 담았다.', 
'https://www.youtube.com/watch?v=PgulubGTFZM&list=RDPgulubGTFZM&start_radio=1', 
TO_DATE('2021-03-05', 'YYYY-MM-DD'), 
10);

-- 67번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
67, 
4, 
'슈베르트: 아르페지오네 소나타 - 미샤 마이스키, 마르타 아르헤리치 [LP]', 
'/images/productimg/67.png', 
20, 
56100, 
'지금은 사라진 악기 ''아르페지오네''를 위하여 작곡된 소나타로 현재는 첼로 연주로 사랑받는다. 슈베르트 작품중 가장 사랑받는 곡중 하나로, 피아노의 여제 아르헤리치와 미샤 마이스키의 유연하고 섬세한 첼로가 조화를 이룬 연주. 1984년 녹음.

클래식 매니아와 오디오파일을 모두 만족시킬 Analogphonic의
최고의 퀄리티로 생산된 LP 발매 5종 (1차분)
180g Pure Virgin Vinyl / German Pressing

1. 원반형 그라모폰을 발명한 에밀 베를리너가 설립하여 100년이 넘는 역사를 지닌 유럽 최고의 마스터링/커팅 전문 스튜디오 에밀 베를리너 스튜디오에서의 커팅
2. 커팅의 마에스트로인 마아르텐 드 보에르(Maarten De Boer)의 최적의 커팅
3. 최적의 사운드를 위한 180g 오디오파일 퓨어 버진 Vinyl의 사용
4. 유럽 최고의 오디오파일 전문 생산 업체 Pallas의 최고 품질의 프레싱', 
'https://www.youtube.com/watch?v=L0Y4UDOrXGM&list=RDL0Y4UDOrXGM&start_radio=1', 
TO_DATE('2022-04-19', 'YYYY-MM-DD'), 
10);

-- 68번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
68, 
4, 
'Alice Sara Ott 존 필드: 녹턴 전곡집 (John Field: Complete Nocturnes) [2LP]', 
'/images/productimg/68.png', 
20, 
87200, 
'야상곡은 쇼팽의 작품이 가장 유명하고, 가장 널리 연주되고 있지만, 소수의 음악 애호가들 사이에서는 존 필드 또한 야상곡의 대표적인 작곡가로 알려져 있다.
존 필드는 쇼팽보다 30여년 앞서 태어난 아일랜드 피아니스트로써, 심지어 ''야상곡'' 이란 단어를 가장 처음 사용한 작곡가이기도 하다.
놀랍게도 알리스 사라 오트의 이 앨범은 DG 레이블에서 처음 녹음된 존 필드의 야상곡집으로 사라 오트의 감성과 잘 어울려 이 레퍼토리의 대표적인 명연으로 남을 것 같다.', 
'https://www.youtube.com/watch?v=3L3HqFiNuu8&list=PL2qQXyLK4-1W9cBXZDNnGxO8jNS_rZoXS', 
TO_DATE('2025-03-20', 'YYYY-MM-DD'), 
10);

-- 69번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
69, 
4, 
'Giuliano Carmignola 비발디: 사계 - 줄리아노 카르미뇰라 (Vivald: The Four Seasons) [LP]', 
'/images/productimg/69.png', 
20, 
48100, 
'연주: 소나토리 데 라 지오이오사 마르카 / 바로크 바이올린: 쥴리아노 카르미뇰라

"세기적인 레코딩" - 지금까지의 감동은 모두 잊어라!
고전음악 레퍼토리 가운데 전 세계에서 가장 많이 연주되는 비발디의 협주곡 4계는 그 유명세만큼이나 명연주 명반들이 즐비하다. 그중에서 누가 선정하더라도 1위 아니면 다섯 손가락 안에는 반드시 꼽힐 명연 중의 명연이 바로 카르미뇰라의 음반이다.
비발디 시대의 오리지널 악기로 연주하고 있고, 옛 악기임에도 놀라울 정도로 자연스럽고 편안하다. 인토네이션이나 앙상블에는 아주 작은 결점도 없이 완벽하고, 비발디 음악의 외관적 특징인 생생한 활력의 아름다움은 특히 빠른 악장에서 찬연하게 빛난다. 협주곡이 시작되자마자 펼쳐지는 화창한 봄날의 정경에 홀딱 반하고, 가을의 협주곡에서의 수수하고 상냥한 춤은 너무 매혹적이어서 가만히 앉아서 듣지 못하게 만든다. 이 이탈리아 악단이 폭발적인 인기를 끈 것은 명료함과 청량감이 극대화된 생생한 활력 때문만은 아니다. 앙상한 가지만 남은 황량한 풍경과 대비되는 겨울 2악장이 흐르면, 따스한 벽난로에서 가슴을 녹여주는 연주의 깊이에 돌연 숙연해진다.
디복스의 놀라운 20비트 녹음 기술이 이 음반이 최고의 인기를 누리는 데 큰 몫을 했다. 생생한 현악기 연주의 장점을 극한까지 보여준다. 금세기 ‘10대 레코딩 중의 하나’로 선정되기도 했다.', 
'https://www.youtube.com/watch?v=CzUP3znfE4U&list=RDCzUP3znfE4U&start_radio=1', 
TO_DATE('2017-07-14', 'YYYY-MM-DD'), 
10);

-- 70번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
70, 
4, 
'피아노로 연주한 디즈니 명곡 (Disney Peaceful Piano) [LP]', 
'/images/productimg/70.png', 
20, 
57100, 
'Sit back and relax by listening to piano renditions of your favorite Disney songs including, "You''ve Got a Friend in Me," "The Family Madrigal" and more.', 
'https://www.youtube.com/watch?v=cyOLHOcLdr4&list=RDcyOLHOcLdr4&start_radio=1', 
TO_DATE('2024-06-25', 'YYYY-MM-DD'), 
10);

-- 71번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
71, 
4, 
'박규희 - 기타 리사이틀 (Kyuhee Park Guitar Recital) [LP]', 
'/images/productimg/71.png', 
20, 
60000, 
'기타리스트 박규희, (2012년 알함브라 콩쿠르 우승자) 낙소스 데뷔 음반을 180g LP로

바로크로부터 현대에 이르는 다양한 작품들을 음반에 담았다.
건반을 위한 D. 스카를라티의 소나타 3편은 자신의 기타 편곡으로, 사랑스럽고 아름답게 노래하는 선율과 함께 넘치는 에너지로 모두의 흥미를 이끌며, 특히 이 음반에서 박규희는 스칼라티의 편곡 과정에서 단순히 악보를 옮기는 정도가 아닌 정교한 이해가 동반된 연주자의 음악적 지성, 섬세한 연주와 트레몰로를 통해 천부적인 재능을 느낄 수 있는 연주 테크닉 둘 다에 감탄하게 된다.
디아벨리의 소나타 Op.29-2와, 말라츠의 유명한 앙코르 피스인 ''세레나타 에스파뇰라''와 바리오스의 ''숲의 꿈'', 현존하는 작곡가 로페스의 ''인상과 풍경'' 등으로 풍부하고 세련된 표현력을 선보인 이 음반을 오디오파일 180g LP로 그녀를 사랑하는 팬들과 오디오 애호가들에게 절대로 놓칠 수 없는 아이템이 되리라 확신한다.', 
'https://www.youtube.com/watch?v=utQ13wDKiTI&list=RDutQ13wDKiTI&start_radio=1', 
TO_DATE('2025-04-29', 'YYYY-MM-DD'), 
10);

-- 72번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
72, 
4, 
'Emil Gilels 브람스: 피아노 협주곡 1, 2번 (Brahms: Piano Concertos Op.15, Op.83) [2LP]', 
'/images/productimg/72.png', 
20, 
110100, 
'2023년 DG 125주년을 맞아 이들의 대표적 명반 가운데서 엄선, 오리지널4트랙 마스터에서 커팅한 진정한 아날로그 오디오파일 LP 시리즈,

두 번째 파트에서는 에밀 길렐스와 요훔이 지휘하는 베를린 필하모닉이 협연한 브람스 피아노 협주곡 1, 2번 전곡 음반이 발매 된다.
스테레오 다운믹스 테이프나 디지털 리마스터를 사용한 것과는 차원이 다른 사운드로 증명된 가운데 두 거장의 역사적 녹음을 만나게 된다.', 
'https://www.youtube.com/watch?v=6n1WVoRyJNQ&list=RD6n1WVoRyJNQ&start_radio=1', 
TO_DATE('2024-11-25', 'YYYY-MM-DD'), 
10);

-- 73번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
73, 
4, 
'정경화 - 비발디: 사계 (Vivaldi: The Four Seasons) [LP]', 
'/images/productimg/73.png', 
20, 
39700, 
'음악과 노래, 자연을 사랑했던 이탈리아 작곡가 비발디와, 그와 같은 감수성을 공유한 한국인 바이올리니스트 정경화가 만들어내는 전통과 현대가 공존하는 비발디 [사계]의 명반이 마침내 LP로 발매된다.

20여년 전 이 작품을 위해 오랜 세월을 기다린 정경화가 심혈을 기울여 바이올린을 들고, 직접 지휘하며 연주한 그녀의 대표적 녹음이다.
인간의 목소리를 대신하는 듯한 ''바이올린''과 조화로운 화음의 ''현악기들''이 만들어내는 뛰어난 비발디의 걸작을 원숙한 바이올리니스트의 무르익은 해석으로 만날 수 있다.', 
'https://www.youtube.com/watch?v=JTILrOX2U-8&list=RDJTILrOX2U-8&start_radio=1', 
TO_DATE('2022-01-21', 'YYYY-MM-DD'), 
10);

-- 74번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
74, 
4, 
'Itzhak Perlman / Yo-Yo Ma 브람스: 이중 협주곡 (Brahms: Double Concerto) [LP]', 
'/images/productimg/74.png', 
20, 
41400, 
'이착 펄만의 80회 생일 맞이해 요요마와 함께 연주한 브람스의 이중 협주곡이 LP로 발매된다. 이 앨범은 이착 펄만의 두 번째 브람스 이중 협주곡 녹음으로, 요요마, 그리고 평생의 음악적 동반자인 바렌보임과 연주해 발매 당시 높은 평가를 받았었다. 펄만이 이전에 로스트로포비치, 하이팅크와 함께 연주한 첫 번째 녹음이 아날로그의 명연이었다면, 이 연주는 디지털 시대의 새로운 명연이 되었다.', 
'https://www.youtube.com/watch?v=5BLU-CaKIt8&list=RD5BLU-CaKIt8&start_radio=1', 
TO_DATE('2025-09-25', 'YYYY-MM-DD'), 
10);

-- 75번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
75, 
4, 
'Moby (모비) - Reprise [2LP]', 
'/images/productimg/75.png', 
20, 
61800, 
'"Go", "Natural Blues", "Porcelain", "Why Does My Heart Feel So Bad?" 등
수많은 히트곡을 만들어낸 아티스트 모비(Moby)가 DG에 입성한다.

다양한 음악 소재를 맛깔나게 섞어 온 그가 자신의 작품들을 완전히 새로운 시각으로 재편하는 것으로, 클래식 악기를 위한 편곡을 통해 지금까지와는 다른 스팩트럼을 보여준다.

LA필과의 공연을 위해 두다멜과 선곡하는 과정에서 떠오른 아이디어를 통해 고유의 일렉트로닉은 물론, 실내악에서 대편성 관현악까지 첨가된 모비의 대표작들을 새롭게 만나게 되는데, 비킹구르 올라프손, 그레고리 포터, 크리스 크리스토퍼슨, 마크 레니건 스카일라 그레이 등 스타급 아티스트들의 피처링이 돋보인다.', 
'https://www.youtube.com/watch?v=gMNB8BqAJdY&list=RDgMNB8BqAJdY&start_radio=1', 
TO_DATE('2021-05-21', 'YYYY-MM-DD'), 
10);

COMMIT;

-- 76번
INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
76, 
4, 
'차이코프스키: 발레음악 `호두까기 인형` - 사이먼 래틀, 베를린 필[2LP]', 
'/images/productimg/76.png', 
20, 
56500, 
'사이먼 래틀이 이끄는 베를린 필하모닉이 연주한 차이코프스키의 인기 발레 [호두까기 인형]이 LP로 발매 된다.
2009년 연말 녹음되어 베를린 필 특유의 유려하고 박진감 넘치는 연주와, 래틀의 생동감 넘치는 리듬감, 그리고 풍성한 사운드의 빼어난 녹음이 각종 매체의 극찬을 받고, 또한 천사의 목소리 리베라 합창단이 참여하여 많은 사랑을 얻은 명반이다.', 
'https://www.youtube.com/watch?v=GVm1cBUyc-M&list=RDGVm1cBUyc-M&start_radio=1', 
TO_DATE('2020-10-23', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
77, 
4, 
'조수미 (Sumi Jo) - Only Love [LP]', 
'/images/productimg/77.png', 
20, 
55100, 
'2000년, 국내 클래식 음반 역사상 전무후무한 100만 장의 판매고를 기록해 모두를 놀라게 한 ‘국민 소프라노’ 조수미의 크로스오버 앨범 [Only Love (온리 러브)]가 발매된 지 20여 년 만에 마장뮤직앤픽처스(주)를 통해 LP로 최초 발매된다.
[Only Love (온리 러브)]는 발매 당시 생소하게 느껴졌던 ‘성악가의 크로스오버 음반’에 대한 편견을 보기 좋게 깨트리며, 클래식 음악계에 돌풍을 일으킨 화제작이다.
조수미는 이 앨범을 분기점으로 다양한 음악 장르에 도전하게 되어 [Only Love (온리 러브)]의 발매를 인생에서 가장 잘한 도전으로 꼽았다.
본 음반에는 [미스 사이공]의 ‘I Still Believe (난 아직 믿어요)’, [지킬 앤 하이드]의 ‘Once Upon A Dream (한때는 꿈에)’, ‘In His Eyes (그의 눈에서)’, ‘Someone Like You (당신 같은 사람)’ 등 유명 브로드웨이 뮤지컬 넘버와 LG DIOS 광고 삽입곡 ‘I Dreamt I Dwelt In Marble Halls’ 등 우리 귀에 친숙한 명곡들이 담겨 있다.
대중에게 더 가까이 다가가려 치열하게 고민한 흔적이 담긴 조수미의 명반 [Only Love (온리 러브)].
LP로 감상한다면, 아날로그 감성이 더해져 더 큰 감동을 느낄 수 있을 것이다.', 
'https://www.youtube.com/watch?v=4Yrq7f4VoQ0&list=RD4Yrq7f4VoQ0&start_radio=1', 
TO_DATE('2021-03-03', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
78, 
4, 
'Daniel Barenboim 베토벤: 교향곡 3, 4, 5번 (Beethoven: Symphonies Nos. 3 Eroica 4 & 5) [3LP]', 
'/images/productimg/78.png', 
20, 
91800, 
'슈타츠카펠레 베를린을 지휘한 베토벤의 교향곡 전집이 2000년에 발매되었을 때, 바렌보임은 이에 대해 다음과 
같은 말을 남겨다. "베토벤 교향곡을 녹음하기 위해 오랫동안 기다렸습니다. 내 안에서 음악이 성숙되기를, 또 음악 안에서 내가 성숙되기를 기다렸고, 단순히 내 지시를 따르는 것이 아니라, 함께 음악을 연주할 때 매순간 같은 것을 느끼는 오케스트라를 찾고 싶었습니다.
이는 지휘자가 가질 수 있는 가장 큰 기쁨이죠" 이 베토벤 전집은 세 번에 걸쳐 LP로 발매될 예정이며, 그 첫 번째 발매에서 교향곡 3, 4, 5번이 수록되었다.', 
'https://www.youtube.com/watch?v=jrlAyokyKGU&list=RDjrlAyokyKGU&start_radio=1', 
TO_DATE('2025-07-01', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
79, 
4, 
'Simon Rattle 홀스트: 혹성 (Holst: The Planets) [LP]', 
'/images/productimg/79.png', 
20, 
41400, 
'사이먼 래틀이 베를린 필하모닉과 함께 2006년 실황으로 녹음한 홀스트의 <혹성>은 베를린 필하모닉이 카라얀과 만든 1981년의 전설적인 음반 이후 무려 25년 만에 발표한 <혹성>이었다. 또한 래틀에게는 필하모니아와 1980년 녹음한 이후 26년 만에 만든 두 번째 <혹성>이기도 했다. 발매 당시 큰 반향을 일으켰던 그 녹음이 LP로 발매된다.', 
'https://www.youtube.com/watch?v=DfbIjVJSzTM&list=RDDfbIjVJSzTM&start_radio=1', 
TO_DATE('2025-11-28', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
80, 
4, 
'레미제라블 10주년 기념 연주회 [2LP]', 
'/images/productimg/80.png', 
20, 
62000, 
'영국의 뮤지컬 제작자 캐머런 맥킨토시가 <레미제라블> 뮤지컬을 런던에 올린 것이 1985년의 일이었다.
이 뮤지컬은 크게 히트했고, 런던에서는 롱런했던 대표적인 뮤지컬이 되었다. 이로부터 10주년이 되었을 때 로열 앨버트 홀에서 콘서트 형식으로 이루어진 공연은 아직까지도 회자될 정도로 전설로 남아 있다.
다행히 이 공연은 녹음으로 남았고, CD와 LP로 재발매되어 그 전설을 우리도 경험하게 되었다.', 
'https://www.youtube.com/watch?v=DVKXI10yo_E&list=RDDVKXI10yo_E&start_radio=1', 
TO_DATE('2025-10-27', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
81, 
5, 
'이날치 - 1집 수궁가 [LP]', 
'/images/productimg/81.png', 
20, 
52800, 
'무서운 입소문의 주인공, 이날치가 내려온다!
이날치는 장영규, 정중엽 두 명의 베이스, 드럼 이철희, 네 명의 판소리 보컬 권송희, 신유진, 안이호, 이나래로 구성된 얼터너티브 팝 밴드다.
이날치는 무대에서 ‘수궁가’를 노래해왔다. ‘수궁가’는 용왕(龍王)이 병이 들자 약에 쓸 토끼의 간을 구하기 위해, 자라는 세상에 나와 토끼를 꾀어 용궁으로 데리고 가고, 토끼는 꾀를 내어 용왕을 속여 살아 돌아온다는 이야기를 판소리로 짠 것이다.
작년 12월부터 차례로 발표한 네 장의 싱글 [어류], [토끼], [호랑이], [자라] 에는 수궁가의 이야기가 파편처럼 흩어져 있었다.
분명히 토끼와 거북이 이야기인데 각종 물고기들이 등장하고, 난데없이 범이 내려오고, 약 이름이 줄줄 나와 의아했다면, 드디어 이번 정규앨범의 10곡을 통해 수궁가의 풀 스토리와 세계관, 치명적 관계, 속고 속이는 플롯을 이해할 수 있게 된다.', 
'https://youtu.be/MJD_fAdqNQc?si=Za4cmgAdEwCPVy_6', 
TO_DATE('2020-06-09', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
82, 
5, 
'강권순 - 지뢰: 땅의 소리 [LP]', 
'/images/productimg/82.png', 
20, 
45800, 
'리듬 표현을 동반하지 않는 ‘정악''.
이 ‘정악’에 내재되어있는 리듬을 구체화시켜 누구나 쉽게 감상하거나 참여할 수 있게 한 앨범이다.
베이시스트이자 음악 프로듀서인 ‘송홍섭’이 편곡하였고, 보컬에는 국가무형문화재 제30호 여창가곡 이수자인 ‘강권순’,
그리고 뛰어난 연주자들이 참여하는 ‘송홍섭 앙상블’이 새로운 관점으로 해석하였다.
2019년 7월 23일 가평뮤직빌리지 음악역 1939 뮤직홀에서 라이브 레코딩으로 진행한 생동감있는 연주이다.
구간구간을 끊어 연주하는 방식이 아닌 몇번의 완곡을 연주하여 완성하는 형태의 레코딩방식으로 많은 시간의 합주를 통해 합을 만들어야하는 힘든 작업이 수반되기에 일반적인 대중음악 장르에서는 사용하지 않는 레코딩 방식이다.', 
'https://youtu.be/eFR3Tt4k0V8?si=uvpDlbLPyjDLvNSa', 
TO_DATE('2019-11-15', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
83, 
5, 
'Yoasobi (요아소비) - IDOL [투명 라이트 블루 컬러 LP]', 
'/images/productimg/83.png', 
20, 
67400, 
'1LP 트랜스페어런트 라이트 블루 한정반

일본을 너어 한국과 세계의 관심을 얻고 있는 YOASOBI.
화제의 애니메이션 [최애의 아이]의 주제가로 2023년 일본 최고의 히트곡 중 하나인 ‘IDOL’의 아날로그 에디션으로 선보이는 이 작품에는 다양한 버전으로 선보이는 ‘IDOL’과 커플링 곡인 ‘TABUN’이 담겨있다.
트랜스페어런트 라이트 블루 사양의 아날로그 에디션!', 
'https://youtu.be/ZRtdQ81jPUQ?si=a6zDPjNGwHlmWIbU', 
TO_DATE('2024-11-14', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
84, 
5, 
'Yamashita Tatsuro (야마시타 타츠로) - CHRISTMAS EVE [7인치 Vinyl]', 
'/images/productimg/84.png', 
20, 
39400, 
'Yamashita Tatsuro [CHRISTMAS EVE] 7인치 2025 버전 완전 생산 한정반(일본생산)

시티 팝의 상징으로 여겨지는 싱어송라이터 야마시타 타츠로.
1984년 야마시타 타츠로가 발표한 이 작품은 일본의 크리스마스 송을 대표하는 영원한 베스트 셀러로 여겨져 왔다.
2025년에 선보이는 이 작품에는 ‘크리스마스 이브’와 함께 커플링 곡으로 ‘화이트 크리스마스’이 담겨있다.
1983년의 오리지널 재킷 디자인을 그대로 채택하여, 발매 이후 42년 만에 오리지널 재킷으로 선보여 더욱 의미가 깊다.', 
'https://youtu.be/1-xwxyHOyVw?si=HFdX2jAjFMrM3a3H', 
TO_DATE('2025-12-16', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
85, 
5, 
'F1 더 무비 영화음악 (F1 The Album OST) [골드 컬러 LP]', 
'/images/productimg/85.png', 
20, 
48700, 
'브래드 피트 주연의 액션 블록버스터 영화 F1의 공식 사운드트랙.
Apple Original Films와 Warner Bros. Pictures가 선보이는 고속질주 액션 영화 F1의 에너지 넘치는 사운드트랙으로, Atlantic Records가 Barbie The Album, Twisters: The Album, The Greatest Showman, Suicide Squad 등 초대형 히트 OST를 잇는 또 하나의 블록버스터 앨범을 완성했다.
Ed Sheeran, Tate McRae, Doja Cat, ROSE, Burna Boy, Chris Stapleton, Don Toliver, RAYE, Tiesto, Myke Towers 등 글로벌 스타들이 참여한 신곡이 대거 수록된 이 앨범은, 영화의 속도감 넘치는 에너지와 완벽하게 어우러진다.', 
'https://youtu.be/WWEs82u37Mw?si=1kwNWjVmE8_yBPGb', 
TO_DATE('2025-07-25', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
86, 
5, 
'케이팝 데몬 헌터스 영화음악 (KPop Demon Hunters From The Netflix Series OST) [LP]', 
'/images/productimg/86.png', 
20, 
65800, 
'전세계를 강타한 케이팝 애니메이션 흥행작 K-Pop Demon Hunters (케이팝 데몬 헌터스) 오리지날 사운드트랙반!
지난 6월 20일 넷플릭스를 통해 공개되어 현재까지도 누적 시청횟수 1위를 달리고 있는 메가톤급 히트작!
본 OST에는 Twice가 부른 ''Takedown''을 시작으로 Huntr/X의 ''How It''s Done'', Saja Boys의 ''Soda Pop'', 빌보드 싱글차트, 영국 싱글차트 동시에 1위에 오른 ''Golden'' 주인공 루미와 진우의 듀엣곡 ''Free''등 총 12곡 수록!
(CD 안에는 포토카드 1종, (3종중 랜덤), 접이식 포스터 삽입 (북클릿을 펼치면 포스터가 됩니다))', 
'https://youtu.be/l8Dr7vzMSVE?si=YICBPV2MxcXTlE7B', 
TO_DATE('2025-10-31', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
87, 
5, 
'위대한 쇼맨 뮤지컬 영화음악 (The Greatest Showman OST) [LP]', 
'/images/productimg/87.png', 
20, 
46600, 
'Hugh Jackman, Michelle Williams 등 헐리웃 최고의 배우들이 참여한 2017년 뮤지컬 영화 ‘The Greatest Showman (위대한 쇼맨)’의 사운드트랙.

Keala Settle의 폭발적인 에너지를 담은 타이틀 ‘This Is Me’를 선두로 Zac Efron과 Zendaya Coleman의 듀엣 ‘Rewrite the Stars’, Hugh Jackman과 Keala Settle의 ‘The Greatest 
Show’, Michelle Williams의 ‘Tightrope’ 같은 넘버가 쇼 비즈니스 탄생을 둘러싼 야망과 상상력, 경이를 표현했다. 한 곡 한 곡, 마지막 소절까지 대담하고 독창적인 사운드 트랙 앨범.', 
'https://youtu.be/NyVYXRD1Ans?si=uL-M0yYTju7zWsxW', 
TO_DATE('2018-05-30', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
88, 
5, 
'위키드: 포 굿 영화음악 (Wicked : For Good - The Soundtrack) [2LP]', 
'/images/productimg/88.png', 
20, 
80200, 
'2024년 흥행에 성공했던 판타지 뮤지컬 영화 Wicked의 두번째 이야기 Wicked: For Good (위키드: 포 굿)[Garefold][2LP] 사운드 
트랙반!

영화는 전작인 Jon M. Chu가 감독을 맡았으며 주연에 Ariana Grande, Cynthia Erivo를 비롯해 Jonathan Bailey, Ethan Slater, Michelle Yeoh, Bowen Yang 등이 출연했다.
영화음악은 2003년 오리지날 뮤지컬 앨범을 프로듀싱 했던 Stephen Schwartz를 중심으로 Stephen Oremus, Greg Wells가 프로듀싱을 맡았으며 Cynthia Erivo가 부른 ''No Place Like Home'', Ariana Grande가 부른 ''The Girl in the Bubble''등 총 11곡을 수록하고 있다.', 
'https://youtu.be/6IvN6s8P9hU?si=ZOvyXzOZ5ARlIqJ9', 
TO_DATE('2025-12-09', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
89, 
5, 
'선재 업고 튀어 (tvN 월화드라마) OST [컬러 3LP]', 
'/images/productimg/89.png', 
20, 
192400, 
'2024년 선풍적인 인기를 끌었던 tvN 드라마 ‘선재 업고 튀어’가 방영 1주년을 맞아 기념 LP를 출시한다.
이번 기념 LP는 선주문 후제작 방식으로, 고유 넘버링이 새겨진 한정 수량만 제작된다.
총 3장의 LP로 구성되며, 지금까지 공개되지 않았던 ‘미공개 스코어’를 비롯해 드라마 대표 OST ‘소나기’의 클럽 버전과 콘서트 버전이 새롭게 수록될 예정이다.', 
'https://youtu.be/9dokaoupejA?si=CRy97_EKnY-whICL', 
TO_DATE('2025-08-01', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
90, 
5, 
'슬기로운 의사생활 시즌 2 드라마 음악 [솔리드 화이트 & 블루 컬러 2LP]', 
'/images/productimg/90.png', 
20, 
91500, 
'드라마 ‘슬기로운 의사생활 시즌2’ 아쉬움을 달래줄 OST LP가 우리의 곁에 찾아온다.
이번 시즌 2LP는 특별히 디스크 2개를 23곡의 노래들로만 꽉 채웠다.
‘Disk 1’은 OST로 출시된 노래 11곡을 담았고 ‘Disk 2’는 ‘미도와 파라솔’의 드라마 버전인 밴드곡으로만 구성되어 ‘미도와 파라솔’ 팬들에게는 특별한 의미가 담긴 선물이 될 것 같다.
뿐만 아니라 ''슬기로운 의사생활'' 시즌1에서만 만나볼 수 있었던 ''론리 나잇''(Lonely Night)을 전미도의 감미로운 목소리로 완성된 버전으로 트랙에 담아 드라마 종영을 아쉬워하는 팬들에게 좋은 보답이 될 전망이다.
또한 슬의생 5인방의 포토스탠드, 배우 사인이 들어간 미니 브로마이드 1종, 한 장으로 된 두툼한 가사지, 화이트&블루의 컬러 디스크 등이 구성되어 CD와는 또 다른 느낌의 음반으로 소장가치를 높여준다.
아울러 일찍 품절되어 아쉬워했던 슬기로운 의사생활 시즌 1 OST LP가 이번에는 블랙디스크 버전으로 재발매 된다.
LP의 특성상 제작기간이 오래 걸리기 때문에 블랙디스크도 한정 수량으로 발매될 예정이니 놓치신 분들은 서둘러야 할 것 같다.
‘슬기로운 의사생활 시즌2’ OST 2LP와 함께 드라마를 그리워하시는 분들에게, OST를 사랑해주신 분들에게 감동이 전해지길 바란다.', 
'https://youtu.be/sCmcSBsTxQc?si=sGugfHALTfFbjq3t', 
TO_DATE('2023-05-02', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
91, 
5, 
'킹더랜드 드라마음악 [컬러 LP]', 
'/images/productimg/91.png', 
20, 
69100, 
'JTBC 토일드라마 ‘킹더랜드’ OST LP

JTBC 드라마 ''킹더랜드''는 웃음을 경멸하는 남자 구원(이준호 분)과 웃어야만 하는 스마일 퀸 천사랑(임윤아 분), 정반대 세상의 두 사람이 호텔리어들의 꿈인 VVIP 라운지 ''킹더랜드''에서 그려내는 로맨스를 담은 작품으로, 두 주연의 환상적인 케미와 개성만점 조연들의 탄탄한 연기력까지 시너지를 일으키며 각종 화제성 지표의 최상위권, ''넷플릭스 글로벌 1위'' 자리를 차지하는 등 변함없는 인기를 입증했다.
이번 한정판 LP에는 시원한 풀밴드 사운드로 극 초반에 깔려 벅차오르는 기대감을 선사했던 OST Part.1 ''Yellow Light - 가호(Gaho)''부터, 레트로한 신디 사운드로 2화 엔딩을 비롯한 많은 로맨틱한 장면에 등장해 많은 시청자들의 심장을 두근거리게 했던 OST Part.5 ''Keep Me Busy - 펀치(Punch)'', 경쾌한 사운드를 중심으로 점점 분위기를 고조시켜 두 주인공의 설레는 감정선을 끌어올렸던 OST Part.4 ''DIVE - 김우진'', 두 사람의 사랑이 점점 더 깊어져가는 가운데, 항상 함께이고 싶지만 한편 멀어질까 조심스럽고 걱정되는 마음을 그려낸 OST Part.8 ''사랑인걸까 - 민서(MINSEO)'', 밝고 경쾌한 사운드로 다수 데이트씬에 삽입되어 대리 설렘을 유발했던 OST Part.9 ''Everyday With You - 경서''까지 ‘원럽’ 커플의 간질거리는 설레임을 담은 곡들이 Side 
A면에 수록되어있다.', 
'https://youtu.be/bJJ1uaF3OL0?si=I-4F4C3YyWp70mm7', 
TO_DATE('2023-10-19', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
92, 
5, 
'10CM (십센치) - 10cm The First EP [솔리드 그레이 컬러 LP]', 
'/images/productimg/92.png', 
20, 
58000, 
'10CM의 [10cm The First EP] Vinyl

2010년 발표된 ‘10cm The First EP’는 단출한 어쿠스틱 편성과 솔직한 가사로 사랑과 청춘의 순간을 담아내며, ‘10CM의 시작을 알린 작품’으로 자리 잡았다.
세련되거나 거창하지 않아도 날 것의 젬베, 기타, 목소리가 만나, 일상의 감정을 그대로 노래한 곡들은 지금까지도 첫사랑 같은 울림을 전한다.
이번 LP에는 ‘10cm The First EP’와 함께 2025년 버전으로 선보이는 “아메리카노 (2025 Ver.)”이 더해졌다.
15년의 시간을 지나 다시 꺼내는 시작의 노래는, 지금의 10CM가 건네는 또 하나의 기록으로 남는다.
아날로그 사운드 속에 새겨진 그 순간의 감정과 현재의 호흡을 함께 경험해 보시길 바란다.', 
'https://youtu.be/vx8eCAMm-CM?si=rNbf_GozXqmgrV5y', 
TO_DATE('2025-11-03', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
93, 
5, 
'하현상 - EP : Elegy [그레이 컬러 LP]', 
'/images/productimg/93.png', 
20, 
60500, 
'하현상, EP ‘Elegy’ 리마스터 LP 발매

싱어송라이터 하현상이 리마스터 LP를 발매한다.
‘Elegy [Remastered]’라는 앨범명으로 발매되는 이번 LP는 지난 2024년 발매된 EP ‘Elegy’의 트랙들이 리마스터링 버전으로 수록돼 아날로그 사운드 고유의 낭만을 느낄 수 있다.
‘Elegy’는 찬연하게 아름다운 사랑을 그린 앨범으로, 하현상은 수록된 모든 곡의 작사와 작곡을 진행하며 자신만의 감성을 유려한 음악적 선율로 녹여냈다.', 
'https://youtu.be/HV32EHAFDi4?si=6w9YgoslYpisdgHQ', 
TO_DATE('2025-04-11', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
94, 
5, 
'델리스파이스 - 1집 [픽쳐디스크 LP]', 
'/images/productimg/94.png', 
20, 
55100, 
'델리스파이스 1집 (180g 1LP PICTURE Record, 리마스터2024)

한국록의 수준을 한단계 올려놓은 한국100대 명반 중 하나
실험적이고 모험적인 사운드를 선보이며 자신들만의 정체성을 보여주었던 델리스파이스는 데뷔앨범을 통해 인디뮤지션이라는 한계를 뛰어 넘어 일약 스타덤에 오르게된다.
깊이감있는 아날로그 사운드 마스터링으로 재탄생한 2024 재발매반입니다.', 
'https://youtu.be/95h_Lhdsvps?si=AFu5jZ1yJXQ-arza', 
TO_DATE('2025-09-15', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
95, 
5, 
'프랑스 샹송 모음집 (Paris En Chansons) [블루 컬러 LP]', 
'/images/productimg/95.png', 
20, 
58600, 
'아다모의 ‘눈이 내리네’, 에디뜨 피아프의 ‘후회하지 않아요’, 이브 몽탕의 ‘고엽’, 자크 브렐의 ‘떠나지 말아요’, 줄리엣 그레코의 ‘파리의 하늘 아래’ 등 프랑스를 대표하는 불명의 샹송 15곡의 특별한 노래들이 담겨있다.', 
'https://youtu.be/Utunv3dX7nY?si=X0KtTWIGbgcFiK2r', 
TO_DATE('2024-05-28', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
96, 
5, 
'아르헨티나 탱고 모음집 (Tango Argentino) [네이비 컬러 LP]', 
'/images/productimg/96.png', 
20, 
49300, 
'180 Gram Audiophile Vinyl1,
111장 한정반
네이비 컬러반', 
'https://youtu.be/rkn8Vp96Wfc?si=A-40PVriUH6p-Ikx', 
TO_DATE('2024-02-23', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
97, 
5, 
'황병기 - 가야금 작품 5집 : 달하 노피곰 [2LP]', 
'/images/productimg/97.png', 
20, 
79500, 
'한국 창작음악의 태두 황병기선생의 2주기 추모 발매

가야금을 비롯해 대금, 거문고, 성악 등 다양한 형태의 창작곡을 통하여 황병기 선생의 깊고도 넓은 음악세계를 조망한 걸작 “달하노피곰”의 최초 LP화

황병기 가야금 작품집 제5집 달하노피곰 LP', 
'https://youtu.be/kbJxUqNlV1s?si=VaVtJWRQfADHmaYj', 
TO_DATE('2025-08-14', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
98, 
5, 
'이재하 - 거문고 산조 [LP]', 
'/images/productimg/98.png', 
20, 
55100, 
'2018년 7월, CD로 발매되어 많은 국악팬들의 사랑을 받은 [이재하 거문고 산조]의 LP반.
이번 음반은 CD반과 달리, 잔향이 풍부한 메인 홀 녹음버전이 수록되어 CD반과는 또 다른 매력을 느낄 수 있다.
존 콜트레인부터 스틸리 댄에 이르기까지 세계적인 아티스트의 음반 마스터링, 커팅을 담당한 미국의 마스터디스크 스튜디오에서 아날로그 릴 테이프 마스터를 사용, 래커 커팅으로 제작되었다는 점도 특징점이다.
“산조란 벗어나지 않아야 할 수많은 법칙과 철저한 관계 속에 한없이 자유로워질 수 있어야 한다. 끝까지 완벽하지 못할 것을 알기에 오늘도 부족한 실력과 모자란 성음을 보완하기 위해 연마한다. 마치 투명한 유리잔에 물을 가득 채워 넘치기 직전의 상태를 끝까지 유지하는 일처럼.”', 
'https://youtu.be/7bb3nIVP7yU?si=aH3jVWbltNW5oPgZ', 
TO_DATE('2019-02-11', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
99, 
5, 
'너의 이름은 애니메이션 음악 [2LP]', 
'/images/productimg/99.png', 
20, 
86100, 
'379만명을 동원한 애니메이션 영화
[너의 이름은.(君の名は。)] 오리지널 사운드 트랙 LP

국내에서 2017년 1월에 개봉한 신카이 마코토 감독의 애니메이션 영화 『너의 이름은(君の名は。)』.
신카이 마코토 감독 특유의 아름다운 작화와 스토리, 이를 극대화하는 RADWIMPS의 음악과의 콜라보레이션으로 화제가 되어 영화의 재개봉, 영화음악 콘서트 등, 2023년에도 음악과 영화.애니메이션을 좋아하는 팬들에게 오래도록 사랑받고 있는 영화 『너의 이름은(君の名は。)』.
본 상품에는 ‘전전전세（movie ver.）’, ‘Sparkle（movie ver.）’을 비롯한 주제가 4곡과 극중 배경음악 22곡이 수록되어 있고, 2장 세트로 구성되어 있다.', 
'https://youtu.be/qvqX5LSxtT8?si=k-66SWPvgHxT7J9I', 
TO_DATE('2024-02-16', 'YYYY-MM-DD'), 
10);

INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, stock, price, productdesc, youtubeurl, registerday, point)
VALUES(
100, 
5, 
'장송의 프리렌 애니메이션 음악 [블루 & 그린 컬러 2LP]', 
'/images/productimg/100.png', 
20, 
81200, 
'O.S.T / FRIEREN: BEYOND JOURNEY''S END (ORIGINAL SOUNDTRACK) (TRANSLUCENT EMERALD GREEN & COBALT BLUE 2LP)

일본 NTV에서 방영된 마법사 프리렌의 여정을 그린 애니메이션 [Frieren: Beyond Journey''S End] 오리지널 사운드트랙.
컬러LP 사양으로 발매가 되었으며 음악은 ''Evan Call''이 담당하고 있다.', 
'https://youtu.be/sSmK6-O-0gk?si=ozWiYOT90CmOT6Co', 
TO_DATE('2025-08-12', 'YYYY-MM-DD'), 
10);


commit;


-- 21번 트랙 (Radiohead)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (97, 21, 1, 'I Promise');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (98, 21, 2, 'Man of War');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (99, 21, 3, 'Lift');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (100, 21, 4, 'Lull (Remastered)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (101, 21, 5, 'Meeting In The Aisle (Remastered)');

-- 22번 트랙 (Queen)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (102, 22, 1, 'Bohemian Rhapsody');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (103, 22, 2, 'Another One Bites The Dust');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (104, 22, 3, 'Killer Queen');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (105, 22, 4, 'Fat Bottomed Girls');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (106, 22, 5, 'Bicycle Race');

-- 23번 트랙 (Pink Floyd)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (107, 23, 1, 'Speak to Me');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (108, 23, 2, 'Eclipse');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (109, 23, 3, 'Breathe (In the Air)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (110, 23, 4, 'On the Run');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (111, 23, 5, 'Time');

-- 24번 트랙 (Liam Gallagher)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (112, 24, 1, 'Wall Of Glass');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (113, 24, 2, 'Bold');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (114, 24, 3, 'Greedy Soul');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (115, 24, 4, 'Paper Crown');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (116, 24, 5, 'For What It''s Worth');

-- 25번 트랙 (Pink Floyd - Wish You Were Here 3LP)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (117, 25, 1, 'Shine On You Crazy Diamond (Pts. 1-5)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (118, 25, 2, 'Welcome to the Machine');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (119, 25, 3, 'Have a Cigar');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (120, 25, 4, 'Wish You Were Here');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (121, 25, 5, 'Shine On You Crazy Diamond (Pts. 6-9)');

-- 26번 트랙 (Oasis - Definitely Maybe)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (122, 26, 1, 'Rock ''n'' roll star');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (123, 26, 2, 'Shakemaker');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (124, 26, 3, 'Live forever');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (125, 26, 4, 'Up in the sky');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (126, 26, 5, 'Columbia');

-- 27번 트랙 (Iron Maiden)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (127, 27, 1, 'Intro: Churchill''s Speech');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (128, 27, 2, 'Aces High');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (129, 27, 3, '2 Minutes To Midnight');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (130, 27, 4, 'The Trooper');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (131, 27, 5, 'Revelations');

-- 28번 트랙 (Oasis - Morning Glory)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (132, 28, 1, 'Hello');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (133, 28, 2, 'Roll With It');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (134, 28, 3, 'Wonderwall');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (135, 28, 4, 'Don''t Look Back In Anger');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (136, 28, 5, 'Hey Now');

-- 29번 트랙 (Food Brain)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (137, 29, 1, 'That Will Do');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (138, 29, 2, 'Naked Mountain');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (139, 29, 3, 'Walts for M.P.B');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (140, 29, 4, 'Liver Juice Vending Machine');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (141, 29, 5, 'Conflict of the Hippo and the Pig');

-- 30번 트랙 (Pink Floyd - Wish You Were Here Color LP)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (142, 30, 1, 'Shine on You Crazy Diamond (PTS. 1-5)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (143, 30, 2, 'Welcome to the Machine');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (144, 30, 3, 'Have a Cigar');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (145, 30, 4, 'Wish You Were Here');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (146, 30, 5, 'Shine on You Crazy Diamond (PTS. 6-9)');

-- 31번 트랙 (Alice in Chains)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (147, 31, 1, 'Rotten Apple');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (148, 31, 2, 'Nutshell');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (149, 31, 3, 'I Stay Away');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (150, 31, 4, 'No Excuses');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (151, 31, 5, 'Whale & Wasp');

-- 32번 트랙 (Black Sabbath - Dehumanizer)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (152, 32, 1, 'Computer God');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (153, 32, 2, 'After All (The Dead)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (154, 32, 3, 'TV Crimes');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (155, 32, 4, 'Letters From Earth');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (156, 32, 5, 'Master Of Insanity');

-- 33번 트랙 (Radiohead - In Rainbows)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (157, 33, 1, '15 Step');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (158, 33, 2, 'Bodysnatchers');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (159, 33, 3, 'Nude');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (160, 33, 4, 'Weird Fishes/Arpeggi');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (161, 33, 5, 'All I Need');

-- 34번 트랙 (Black Sabbath - Headless Cross)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (162, 34, 1, 'The Gates Of Hell');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (163, 34, 2, 'Headless Cross');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (164, 34, 3, 'Devil & Daughter');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (165, 34, 4, 'When Death Calls');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (166, 34, 5, 'Kill In The Spirit World');

-- 35번 트랙 (Porcupine Tree)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (167, 35, 1, 'Blackest Eyes [04:24]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (168, 35, 2, 'Trains [05:55]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (169, 35, 3, 'Lips Of Ashes [04:39]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (170, 35, 4, 'The Sound Of Muzak [04:58]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (171, 35, 5, 'Gravity Eyelids [07:56]');

-- 36번 트랙 (Mazzy Star)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (172, 36, 1, 'Fade Into You');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (173, 36, 2, 'Bells Ring');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (174, 36, 3, 'Mary Of Silence');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (175, 36, 4, 'Five String Serenade');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (176, 36, 5, 'Blue Light');

-- 37번 트랙 (Imagine Dragons)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (177, 37, 1, 'I Don''t Know Why');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (178, 37, 2, 'Whatever It Takes');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (179, 37, 3, 'Believer');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (180, 37, 4, 'Walking The Wire');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (181, 37, 5, 'Rise Up');

-- 38번 트랙 (Dry Cleaning)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (182, 38, 1, 'Anna Calls From The Arctic');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (183, 38, 2, 'Kwenchy Kups');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (184, 38, 3, 'Gary Ashby');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (185, 38, 4, 'Driver''s Story');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (186, 38, 5, 'Hot Penny Day');

-- 39번 트랙 (Billie Eilish)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (187, 39, 1, '!!!!!!!');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (188, 39, 2, 'bad guy');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (189, 39, 3, 'xanny');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (190, 39, 4, 'you should see me in a crown');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (191, 39, 5, 'all the good girls go to hell');

-- 40번 트랙 (Pink Floyd - The Wall)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (192, 40, 1, 'In The Flesh?');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (193, 40, 2, 'The Thin Ice');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (194, 40, 3, 'Another Brick In The Wall Part 1');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (195, 40, 4, 'The Happiest Days Of Our Lives');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (196, 40, 5, 'Another Brick In The Wall Part 2');


commit;


-- 41번 트랙 (Christmas Jazz)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (197, 41, 1, 'THE CHRISTMAS SONG - NAT KING COLE');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (198, 41, 2, 'ALL I WANT FOR CHRISTMAS - NAT KING COLE');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (199, 41, 3, 'SLEIGH RIDE - ELLA FITZGERALD');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (200, 41, 4, 'RUDOLPH THE RED NOSED REINDEER - ELLA FITZGERALD');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (201, 41, 5, 'SILENT NIGHT, HOLY NIGHT - DINAH WASHINGTON');

-- 42번 트랙 (Charlie Brown Christmas)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (202, 42, 1, 'O Tannenbaum');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (203, 42, 2, 'What Child Is This');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (204, 42, 3, 'My Little Drum');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (205, 42, 4, 'Linus And Lucy');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (206, 42, 5, 'Christmas Time Is Here');

-- 43번 트랙 (Miles Davis)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (207, 43, 1, '[Side A] So What');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (208, 43, 2, 'Freddie Freeloader');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (209, 43, 3, 'Blue in Green');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (210, 43, 4, '[Side B] All Blues');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (211, 43, 5, 'Flamenco Sketches');

-- 44번 트랙 (Chet Baker Sings)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (212, 44, 1, 'That Old Feeling');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (213, 44, 2, 'It’s Always You');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (214, 44, 3, 'Like Someone in Love');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (215, 44, 4, 'My Ideal');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (216, 44, 5, 'I’ve Never Been in Love Before');

-- 45번 트랙 (Laufey - Bewitched)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (217, 45, 1, 'Dreamer');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (218, 45, 2, 'Second Best');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (219, 45, 3, 'Haunted');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (220, 45, 4, 'Must Be Love');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (221, 45, 5, 'While You Were Sleeping');

-- 46번 트랙 (Bill Evans - Portrait)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (222, 46, 1, 'Come Rain or Come Shine');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (223, 46, 2, 'Autumn Leaves');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (224, 46, 3, 'Witchcraft');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (225, 46, 4, 'When I Fall in Love');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (226, 46, 5, 'Peri’s Scope');

-- 47번 트랙 (Jimmy Smith) *원본 데이터에 1곡만 기재됨
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (227, 47, 1, 'Blues After All');

-- 48번 트랙 (Jazz Brazil)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (228, 48, 1, 'Desafinado - Stan Getz & Charlie Byrd');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (229, 48, 2, 'Loie - Ike Quebec & Kenny Burrell');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (230, 48, 3, 'Se E Tarde, Me Perdoa - Cal Tjader & Clare Fischer');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (231, 48, 4, 'Vento Fresco - Dave Brubeck & Paul Desmond');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (232, 48, 5, 'S.Amba De Uma Nota So (One Note Samba) - Dizzy Gillespie & Lalo Schifrin');

-- 49번 트랙 (Laufey - Typical of Me)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (233, 49, 1, 'Street By Street');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (234, 49, 2, 'Magnolia');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (235, 49, 3, 'Like the Movies');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (236, 49, 4, 'I Wish You Love');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (237, 49, 5, 'James');

-- 50번 트랙 (Laufey - A Matter Of Time)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (238, 50, 1, 'Clockwork');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (239, 50, 2, 'Lover Girl');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (240, 50, 3, 'Snow White');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (241, 50, 4, 'Castle In Hollywood');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (242, 50, 5, 'Carousel');

-- 51번 트랙 (Bill Evans Trio - Waltz For Debby)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (243, 51, 1, 'My Foolish Heart');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (244, 51, 2, 'Waltz For Debby');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (245, 51, 3, 'Detour Ahead');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (246, 51, 4, 'My Romance');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (247, 51, 5, 'Some Other Time');

-- 52번 트랙 (Duke Jordan)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (248, 52, 1, 'No Problem (Jordan)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (249, 52, 2, 'Here''s That Rainy Day (Burke/vanheusen)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (250, 52, 3, 'Everything Happens To Me (Adair/dennis)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (251, 52, 4, 'Glad I Met Pat (Jordan)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (252, 52, 5, 'How Deep Is The Ocean? (Berlin)');

-- 53번 트랙 (Keith Jarrett - The Melody At Night)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (253, 53, 1, 'I Loves You Porgy');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (254, 53, 2, 'I Got It Bad And That Ain''t Good');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (255, 53, 3, 'Don''t Ever Leave Me');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (256, 53, 4, 'Someone To Watch Over Me');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (257, 53, 5, 'My Wild Irish Rose');

-- 54번 트랙 (Take Five)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (258, 54, 1, 'Take Five - Dave Brubeck Quartet');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (259, 54, 2, 'Blues March - Art Blakey & The Jazz Messengers');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (260, 54, 3, 'My Funny Valentine - Miles Davis Quartet');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (261, 54, 4, 'Bye Bye Blackbird - Ben Webster & Oscar Peterson');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (262, 54, 5, 'Cast Your Fate To The Wind - Vince Guaraldi Trio');

-- 55번 트랙 (Keith Jarrett - Koln Concert) *원본 데이터에 2곡만 기재됨
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (263, 55, 1, 'Koln, January 24, 1975 (Part I)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (264, 55, 2, 'Koln, January 24, 1975 (Part II A)');

-- 56번 트랙 (Chet Baker - I Fall In Love)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (265, 56, 1, 'But Not For Me');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (266, 56, 2, 'Over The Rainbow');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (267, 56, 3, 'I Fall In Love Too Easily');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (268, 56, 4, 'You & The Night & The Music');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (269, 56, 5, 'The More I See You');

-- 57번 트랙 (Johnny Griffin) *원본 데이터에 4곡만 기재됨
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (270, 57, 1, 'The Way You Look Tonight');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (271, 57, 2, 'Ball Bearing');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (272, 57, 3, 'All The Things You Are');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (273, 57, 4, 'Smoke Stack');

-- 58번 트랙 (Chet Baker & Bill Evans)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (274, 58, 1, 'Alone Together');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (275, 58, 2, 'How High The Moon');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (276, 58, 3, 'It Never Entered My Mind');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (277, 58, 4, 'Tis Autumn');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (278, 58, 5, 'If You Could See Me Now');

-- 59번 트랙 (Moon / Tsuyoshi Yamamoto)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (279, 59, 1, 'Solitary Moon');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (280, 59, 2, 'Dream a Little Dream of Me');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (281, 59, 3, 'Early Autumn');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (282, 59, 4, 'Mood Indigo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (283, 59, 5, 'Midnight Sun Will Never Set');

-- 60번 트랙 (Archie Shepp)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (284, 60, 1, 'Syeeda''s Song Flute [8:26]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (285, 60, 2, 'Mr. Syms [7:38]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (286, 60, 3, 'Cousin Mary [7:11]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (287, 60, 4, 'Naima [7:06]');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (288, 60, 5, 'Rufus (Swung, His Face At Last To The Wind, Then His Neck Snapped) [6:23]');

-- 61번 트랙 (임윤찬 - 바흐: 골드베르크)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (289, 61, 1, '1. Aria (Title)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (290, 61, 2, 'Var. 1. a 1 Clav.');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (291, 61, 3, 'Var. 2. a 1 Clav.');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (292, 61, 4, 'Var. 3. Canone all''Unisono a 1 Clav.');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (293, 61, 5, 'Var. 4. a 1 Clav.');

-- 62번 트랙 (임윤찬 - 차이콥스키: 사계)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (294, 62, 1, 'I. January. By the Fireside. Moderato semplice ma espressivo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (295, 62, 2, 'II. February. Carnaval. Allegro giusto');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (296, 62, 3, 'III. March. Song of the Lark. Andantino espressivo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (297, 62, 4, 'IV. April. Snowdrop. Allegretto con moto e un poco rubato');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (298, 62, 5, 'V. May. White Nights. Andantino');

-- 63번 트랙 (조성진 - 라벨)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (299, 63, 1, '(CONCERTO FOR PIANO AND ORCHESTRA IN G MAJOR M 83)1 I. Allegramente (8:37)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (300, 63, 2, 'II. Adagio assai (9:42)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (301, 63, 3, 'III. Presto (4:00)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (302, 63, 4, '(CONCERTO FOR THE LEFT HAND FOR PIANO AND ORCHESTRA IN D MAJOR M 82)4 I. Lento (8:48)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (303, 63, 5, 'II. Allegro (4:48)');

-- 64번 트랙 (Enrico Mainardi - Bach Cello)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (304, 64, 1, 'Suite No.1 in G major, BWV 1007');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (305, 64, 2, 'Suite No.2 in D minor, BWV 1008');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (306, 64, 3, 'Suite No.3 in C major, BWV 1009');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (307, 64, 4, 'Suite No.4 in E-flat major, BWV 1010');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (308, 64, 5, 'Suite No.5 in C minor, BWV 1011 ? Prelude-Allemande-Courante');

-- 65번 트랙 (Ghibli Piano)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (309, 65, 1, 'Deep Sea Ranch - From Ponyo on the Cliff by the Sea [벼랑 위의 포뇨] (03:06)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (310, 65, 2, 'Path of the Wind - From My Neighbor Totoro [이웃집 토토로] (02:18)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (311, 65, 3, 'The Wind of Time - From Porco Rosso [붉은 돼지] (02:15)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (312, 65, 4, '6th Station - From Spirited Away [센과 치히로의 행방불명] (04:31)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (313, 65, 5, 'One Summer''s Day - From Spirited Away [센과 치히로의 행방불명] (05:27)');

-- 66번 트랙 (Hilary Hahn - Paris)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (314, 66, 1, 'Chausson: Poeme for Violin and Orchestra, Op. 25 - 1. Andantino - Andante assai');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (315, 66, 2, 'Chausson: Poeme for Violin and Orchestra, Op. 25 - 2. Scherzo. Vivacissimo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (316, 66, 3, 'Chausson: Poeme for Violin and Orchestra, Op. 25 - 3. Moderato - Allegro moderato - Moderato - Piu tranquillo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (317, 66, 4, 'Prokofiev: Violin Concerto No.1 in D, Op.19');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (318, 66, 5, 'Rautavaara : Two Serenades Dedicated to Hilary Hahn - No. 1. Serenade pour mon amour. Moderato');

-- 67번 트랙 (Schubert - Arpeggione) *원본 데이터에 3곡만 기재됨
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (319, 67, 1, 'Schubert : Sonata for Arpeggione and Piano In a minor D.821');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (320, 67, 2, 'Schumann : Fantaisies for Cello and Piano op.73');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (321, 67, 3, 'Schumann : 5 Stucke Im Volkston for Piano and Cello op.102');

-- 68번 트랙 (Alice Sara Ott - John Field)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (322, 68, 1, 'Nocturne No. 1 in E-Flat Major');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (323, 68, 2, 'Nocturne No. 2 in C Minor');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (324, 68, 3, 'Nocturne No. 3 in A-Flat Major,');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (325, 68, 4, 'Nocturne No. 4 in A Major');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (326, 68, 5, 'Nocturne No. 5 in B-Flat Major');

-- 69번 트랙 (Giuliano Carmignola - Vivaldi)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (327, 69, 1, 'The Spring Op.8 No.1 Rv 269: I. Allegro');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (328, 69, 2, 'The Spring Op.8 No.1 Rv 269: Ii. Largo Pianissimo Semre');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (329, 69, 3, 'The Spring Op.8 No.1 Rv 269: Iii. Danza Pastorale. Allegro');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (330, 69, 4, 'The Summer Op.8 No.2 Rv 315: I. Allegro Non Molto');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (331, 69, 5, 'The Summer Op.8 No.2 Rv 315: Ii. Adagio-Presto');

-- 70번 트랙 (Disney Peaceful Piano)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (332, 70, 1, 'A Dream Is a Wish Your Heart Makes');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (333, 70, 2, 'All Is Found');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (334, 70, 3, 'A Whole New World');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (335, 70, 4, 'Beauty and the Beast');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (336, 70, 5, 'Ca You Feel the Love Tonighto');

-- 71번 트랙 (박규희 - 기타 리사이틀)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (337, 71, 1, 'Domenico Scarlatti: Keyboard Sonata in D Major, K.178/L.162/P.392 (arr. Kyuhee Park for guitar)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (338, 71, 2, 'Domenico Scarlatti: Keyboard Sonata in D Minor, K.32/L.423/P.14 (arr. Kyuhee Park for guitar)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (339, 71, 3, 'Domenico Scarlatti: Keyboard Sonata in G Major, K.14/L.387/P.70 (arr. Kyuhee Park for guitar)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (340, 71, 4, 'Agustin Barrios Mangore: Un sueno en la floresta');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (341, 71, 5, 'Agustin Barrios Mangore: Vals, Op. 8, No. 4');

select *
From tbl_track;

-- 72번 트랙 (Emil Gilels - Brahms)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (342, 72, 1, 'I. Maestoso Poco piu moderato');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (343, 72, 2, 'II. Adagio');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (344, 72, 3, 'III. Rondo (Allegro non troppo)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (345, 72, 4, 'I. Allegro non troppo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (346, 72, 5, 'II. Allegro appassionato');

-- 73번 트랙 (정경화 - 비발디: 사계)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (347, 73, 1, 'Vivaldi: The Four Seasons - Concerto in E major "La primavea" / "Spring", Op.8 No.1 (RV269) - I. Allegro');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (348, 73, 2, 'II. Largo');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (349, 73, 3, 'III. Allegro');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (350, 73, 4, 'Concerto in G minor "L''estate" / "Summer", Op.8 No.2 (RV315) - I. Allegro non molto');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (351, 73, 5, 'II. Adagio');

-- 74번 트랙 (Perlman/Ma - Brahms)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (352, 74, 1, 'I. Allegro maestoso');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (353, 74, 2, 'II. Andante');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (354, 74, 3, 'III. Presto');

-- 75번 트랙 (Moby - Reprise)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (355, 75, 1, 'Everloving');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (356, 75, 2, 'Natural Blues - feat Gregory Porter & Amythyst Kiah');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (357, 75, 3, 'Go');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (358, 75, 4, 'Porcelain - feat Jim James (My Morning Jacket) & Vikingur Olafsson');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (359, 75, 5, 'Extreme Ways - Moby');

-- 76번 트랙 (Simon Rattle - Nutcracker)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (360, 76, 1, 'Tchaikovsky : The nutcracker - no.1 the decoration of the christmas tree');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (361, 76, 2, 'no.2 march');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (362, 76, 3, 'no.3 children''s galop and entry of the pare');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (363, 76, 4, 'no.4 arrival of drosselmeyer');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (364, 76, 5, 'no.5 grandfather''s dance');

-- 77번 트랙 (조수미 - Only Love)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (365, 77, 1, 'I Dreamt I Dwelt In Marble Halls [From The Bohemian Girl] (대리석 궁전에 사는 꿈을 꾸었네 - 오페라 "보헤미안 걸") 3:46');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (366, 77, 2, 'Beautiful World (아름다운 세상) 4:59');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (367, 77, 3, 'Once Upon A Dream [From Jekyll And Hyde] (한때는 꿈에 - 뮤지컬 "지킬 앤 하이드") 3:08');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (368, 77, 4, 'Unusual Way [From Nine] (언유즈얼 웨이 - 뮤지컬 "나인") 3:05');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (369, 77, 5, 'I Still Believe [From Miss Saigon] (난 아직 믿어요 - 뮤지컬 "미스 사이공") 4:08');

-- 78번 트랙 (Daniel Barenboim - Beethoven)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (370, 78, 1, 'Symphony No. 3 in E-Flat Major, Op. 55 "Eroica" I. Allegro Con Brio');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (371, 78, 2, 'II. Marcia Funebre: Adagio Assai');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (372, 78, 3, 'III. Scherzo: Allegro Vivace');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (373, 78, 4, 'IV. Finale. Allegro Molto');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (374, 78, 5, 'Symphony No. 4 in B-Flat Major, Op. 60: I. Adagio - Allegro Vivace');

-- 79번 트랙 (Simon Rattle - Holst)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (375, 79, 1, 'The Planets, Op. 32: I. Mars, the Bringer of War');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (376, 79, 2, 'The Planets, Op. 32: II. Venus, the Bringer of Peace');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (377, 79, 3, 'The Planets, Op. 32: III. Mercury, the Winged Messenger');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (378, 79, 4, 'The Planets, Op. 32: IV. Jupiter, the Bringer of Jollity');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (379, 79, 5, 'The Planets, Op. 32: V. Saturn, the Bringer of Old Age');

-- 80번 트랙 (Les Miserables 10th)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (380, 80, 1, 'Prologue / Look Down (Live)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (381, 80, 2, 'Valjean''s Soliloquy (Live)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (382, 80, 3, 'At the End of the Day (Live)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (383, 80, 4, 'I Dreamed a Dream (Live)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (384, 80, 5, 'Lovely Ladies (Live)');

-- 81번 트랙 (이날치 - 수궁가)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (385, 81, 1, '어류도감');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (386, 81, 2, '좌우나졸');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (387, 81, 3, '범 내려온다');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (388, 81, 4, '별주부가 울며 여짜오되');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (389, 81, 5, '일개 한퇴');

-- 82번 트랙 (강권순 - 지뢰)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (390, 82, 1, '수양산가');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (391, 82, 2, '계면조 편수대엽');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (392, 82, 3, '계면조 중거');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (393, 82, 4, '길군악');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (394, 82, 5, '우조 이수대엽');

-- 83번 트랙 (Yoasobi - IDOL)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (395, 83, 1, 'Idol');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (396, 83, 2, 'Idol (English Version)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (397, 83, 3, 'Idol (Anime Edit)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (398, 83, 4, 'Idol (Sped Up & Pitch Up Version)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (399, 83, 5, 'Idol (Instrumental)');

-- 84번 트랙 (Yamashita Tatsuro)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (400, 84, 1, 'Christmas Eve');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (401, 84, 2, 'White Christmas');

-- 85번 트랙 (F1 The Album)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (402, 85, 1, 'Don Toliver- Lose My Mind (Feat. Doja Cat)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (403, 85, 2, 'Dom Dolla- No Room for a Saint (Feat. Nathan Nicholson)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (404, 85, 3, 'Ed Sheeran- Drive');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (405, 85, 4, 'Tate McRae- Just Keep Watching');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (406, 85, 5, 'Rose - Messy');

-- 86번 트랙 (KPop Demon Hunters)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (407, 86, 1, 'TAKEDOWN - TWICE (Jeongyeon, Jihyo, Chaeyoung)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (408, 86, 2, 'How It''s Done - HUNTR/X (EJAE, Audrey Nuna, and REI AMI)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (409, 86, 3, 'Soda Pop - Saja Boys (Andrew Choi, Neckwav, Danny Chung, Kevin Woo, and samUIL Lee)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (410, 86, 4, 'Golden - HUNTR/X (EJAE, Audrey Nuna, and REI AMI)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (411, 86, 5, 'Strategy - TWICE');

-- 87번 트랙 (The Greatest Showman)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (412, 87, 1, 'The Greatest Show - Hugh Jackman, Keala Settle, Zac Efron, Zendaya & T');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (413, 87, 2, 'A Million Dreams - Ziv Zaifman, Hugh Jackman, Michelle Williams');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (414, 87, 3, 'A Million Dreams (Reprise) - Austyn Johnson, Cameron Seely, Hugh Jackman');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (415, 87, 4, 'Come Alive - Hugh Jackman, Keala Settle, Daniel Everidge, Zenda');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (416, 87, 5, 'The Other Side - Hugh Jackman & Zac Efron');

-- 88번 트랙 (Wicked)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (417, 88, 1, 'Every Day More Wicked - Wicked Movie Cast, Cynthia Erivo ft. Michelle Yeoh, Ariana Grande');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (418, 88, 2, 'Thank Goodness / I Couldn’t Be Happier - Ariana Grande, Wicked Movie Cast ft. Michelle Yeoh-');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (419, 88, 3, 'No Place Like Home - Cynthia Erivo-');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (420, 88, 4, 'The Wicked Witch of the East - Marissa Bode, Cynthia Erivo, Ethan Slater');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (421, 88, 5, 'Wonderful - Jeff Goldblum, Ariana Grande, Cynthia Erivo');

-- 89번 트랙 (선재 업고 튀어 OST)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (422, 89, 1, 'Star - 엔플라잉 (N.Flying)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (423, 89, 2, '꿈결같아서 - 민니 ((여자)아이들)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (424, 89, 3, '이 마음을 전해도 될까 - 엄지 (UMJI)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (425, 89, 4, '슈퍼울트라맨 - 든든맨');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (426, 89, 5, 'A Day - 종호(ATEEZ)');

-- 90번 트랙 (슬기로운 의사생활 2)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (427, 90, 1, '비와당신 - 이무진');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (428, 90, 2, '가을 우체국 앞에서 - 김대명');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (429, 90, 3, '나는 너 좋아 - 장범준');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (430, 90, 4, '누구보다 널 사랑해 - TWICE (트와이스)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (431, 90, 5, '좋아좋아 - 조정석');

-- 91번 트랙 (킹더랜드)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (432, 91, 1, 'Yellow Light - 가호(Gaho)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (433, 91, 2, 'Keep Me Busy - 펀치(Punch)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (434, 91, 3, 'DIVE - 김우진');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (435, 91, 4, '사랑인걸까 - 민서(MINSEO)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (436, 91, 5, 'Everyday With You - 경서');

-- 92번 트랙 (10CM)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (437, 92, 1, '눈이 오네');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (438, 92, 2, '새벽 4시');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (439, 92, 3, 'Healing');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (440, 92, 4, 'Good Night');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (441, 92, 5, '죽겠네');

-- 93번 트랙 (하현상)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (442, 93, 1, '비행');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (443, 93, 2, '향기');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (444, 93, 3, '계절비');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (445, 93, 4, '나도 모르게');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (446, 93, 5, '송가');

-- 94번 트랙 (델리스파이스)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (447, 94, 1, '노캐리어');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (448, 94, 2, '가면');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (449, 94, 3, '차우차우-아무리 애를 쓰고 막아보려 해도 너의 목소리가 들려');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (450, 94, 4, '콘 후레이크');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (451, 94, 5, '기쁨이 들리지 않는 거리');

-- 95번 트랙 (프랑스 샹송)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (452, 95, 1, 'Paname (Leo Ferre) 1961 - Leo Ferre');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (453, 95, 2, 'Le poinconneur des Lilas (Serge Gainsbourg) 1958 - Serge Gainsbourg');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (454, 95, 3, 'A Paris (Nathan Korb) 1949 - Francis Lemarque');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (455, 95, 4, 'Sous le ciel de Paris (Jean Drejac, Hubert Giraud) 1951 - Juliette Greco');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (456, 95, 5, 'Mademoiselle de Paris (Henri Contet, Paul Durand) 1953 - Jacqueline Francois');

-- 96번 트랙 (아르헨티나 탱고)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (457, 96, 1, 'Uno - Edmundo Rivero');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (458, 96, 2, 'A Media Luz - Cuarteto Palais De Glace');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (459, 96, 3, 'Por una Cabeza - Carlos Aragon');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (460, 96, 4, 'Se dice de mi - Quinteto Pirincho');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (461, 96, 5, 'Tango Argentino - Vicente Alvarez y Carlos Otero');

-- 97번 트랙 (황병기 - 가야금)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (462, 97, 1, '달하 노피곰');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (463, 97, 2, '시계탑');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (464, 97, 3, '하마단');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (465, 97, 4, '자시(子時)');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (466, 97, 5, '낙도음(樂道吟)');

-- 98번 트랙 (이재하 - 거문고)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (467, 98, 1, '[긴 산조] 다스름 Dasrum');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (468, 98, 2, '진양 JinYang');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (469, 98, 3, '[긴 산조] 중모리 Jungmori');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (470, 98, 4, '중중모리 Jungjungmori');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (471, 98, 5, '늦은 자진모리 Slower Jajinmori');

-- 99번 트랙 (너의 이름은)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (472, 99, 1, '夢?籠');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (473, 99, 2, '三葉の通?');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (474, 99, 3, '?守高校');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (475, 99, 4, 'はじめての、東京');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (476, 99, 5, '憧れカフェ');

-- 100번 트랙 (장송의 프리렌)
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (477, 100, 1, 'Journey of a Lifetime ~ Frieren Main Theme');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (478, 100, 2, 'The End of One Journey');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (479, 100, 3, 'A Well-Earned Celebration');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (480, 100, 4, 'For 1000 Years');
INSERT INTO tbl_track (trackno, fk_productno, track_order, track_title) VALUES (481, 100, 5, 'One Last Adventure');

commit;

select count(*)
from tbl_track;
