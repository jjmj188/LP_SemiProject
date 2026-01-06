show user;
-- USER?´(ê°?) "SEMI_ORAUSER3"?…?‹ˆ?‹¤.


  
--?šŒ?›?…Œ?´ë¸?
CREATE TABLE tbl_member
(
    userid            VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?””(PK) 
  , pwd               VARCHAR2(200) NOT NULL -- ë¹„ë?ë²ˆí˜¸ : SHA-256 ?•”?˜¸?™” ???¥
  , name              VARCHAR2(30) NOT NULL -- ?šŒ?›ëª? 
  , email             VARCHAR2(200) NOT NULL -- ?´ë©”ì¼ : AES-256 ?•”?˜¸?™” ???ƒ, ì¤‘ë³µ ë¶ˆê?
  , mobile            VARCHAR2(200) -- ?œ´???°ë²ˆí˜¸ : AES-256 ?•”?˜¸?™” ???ƒ
  , gender            VARCHAR2(1) -- ?„±ë³? : ?‚¨?(1), ?—¬?(2)
  , birthday          VARCHAR2(10) -- ?ƒ?…„?›”?¼ 
  , registerday       DATE DEFAULT SYSDATE -- ê°??…?¼? 
  , lastpwdchangedate DATE DEFAULT SYSDATE -- ë§ˆì?ë§‰ì•”?˜¸ë³?ê²½ë‚ ì§œì‹œê°? 
  , status             number(1) default 1 not null     -- ?šŒ?›?ƒˆ?‡´?œ ë¬?   1: ?‚¬?š©ê°??Š¥(ê°??…ì¤?) / 0:?‚¬?š©ë¶ˆëŠ¥(?ƒˆ?‡´) 
  , point             NUMBER DEFAULT 0 -- ?¬?¸?Š¸
  , idle               number(1) default 0 not null     -- ?œ´ë©´ìœ ë¬?      0 : ?™œ?™ì¤?  /  1 : ?œ´ë©´ì¤‘ 
  , CONSTRAINT PK_tbl_member_userid PRIMARY KEY (userid)  
  , CONSTRAINT UQ_tbl_member_email UNIQUE (email) -- ?´ë©”ì¼ ì¤‘ë³µ ë°©ì?
  , CONSTRAINT CK_tbl_member_gender CHECK (gender IN ('1','2')) -- ?„±ë³?   ?‚¨?:1  / ?—¬?:2
  , CONSTRAINT CK_tbl_member_status CHECK (status IN (0,1)) -- ?šŒ?›?ƒˆ?‡´?œ ë¬? ê°? ? œ?•œ
  ,constraint CK_tbl_member_idle check( idle in(0,1) )
);




--ë¡œê·¸?¸ ê¸°ë¡ ?…Œ?´ë¸?
create table tbl_loginhistory
(historyno   number
,fk_userid   varchar2(40) not null  -- ?šŒ?›?•„?´?””
,logindate   date default sysdate not null -- ë¡œê·¸?¸?˜?–´ì§? ? ‘?†?‚ ì§œë°?‹œê°?
,clientip    varchar2(20) not null -- ? ‘?†?•œ ?´?¼?´?–¸?Š¸ IP ì£¼ì†Œ
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

-- ì¹´í…Œê³ ë¦¬ ?…Œ?´ë¸?
CREATE TABLE tbl_category
(
    categoryno NUMBER -- ì¹´í…Œê³ ë¦¬ë¶„ë¥˜ë²ˆí˜¸(PK) 
  , categoryname VARCHAR2(50) NOT NULL -- ì¹´í…Œê³ ë¦¬ëª? (POP, ROCK, JAZZ, CLASSIC, ETC)
  , CONSTRAINT PK_tbl_category PRIMARY KEY (categoryno)
);

select * from  tbl_category;

-- ì´ˆê¸°?°?´?„°
INSERT INTO tbl_category VALUES (1, 'POP');
INSERT INTO tbl_category VALUES (2, 'ROCK');
INSERT INTO tbl_category VALUES (3, 'JAZZ');
INSERT INTO tbl_category VALUES (4, 'CLASSIC');
INSERT INTO tbl_category VALUES (5, 'ETC');


-- ?šŒ?›ì·¨í–¥?…Œ?´ë¸?
CREATE TABLE tbl_member_preference
(
    fk_userid     VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?”” (FK)
  , fk_categoryno NUMBER NOT NULL       -- ì¹´í…Œê³ ë¦¬ ë²ˆí˜¸ (FK)

  -- ?•œ ?šŒ?›?´ ê°™ì? ì·¨í–¥?„ ì¤‘ë³µ ?„ ?ƒ?•˜ì§? ëª»í•˜?„ë¡? ë³µí•© PK ?„¤? •
  , CONSTRAINT PK_tbl_member_preference
        PRIMARY KEY (fk_userid, fk_categoryno)

  -- ?šŒ?› ?…Œ?´ë¸? ì°¸ì¡°
  , CONSTRAINT FK_tbl_member_preference_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)

  -- ì¹´í…Œê³ ë¦¬ ?…Œ?´ë¸? ì°¸ì¡°
  , CONSTRAINT FK_tbl_member_preference_category
        FOREIGN KEY (fk_categoryno)
        REFERENCES tbl_category(categoryno)
);

 
-- ? œ?’ˆ ?…Œ?´ë¸?
CREATE TABLE tbl_product
(
    productno NUMBER -- ? œ?’ˆë²ˆí˜¸(PK) 
  , fk_categoryno NUMBER NOT NULL -- ì¹´í…Œê³ ë¦¬ë¶„ë¥˜ë²ˆí˜¸(FK) : tbl_category.categoryno ì°¸ì¡°
  , productname VARCHAR2(100) NOT NULL -- ? œ?’ˆëª? 
  , productimg VARCHAR2(200) -- ? œ?’ˆ?´ë¯¸ì? 
  , stock NUMBER DEFAULT 20 -- ? œ?’ˆ?¬ê³ ëŸ‰ : ?˜„?¬ ?Œë§? ê°??Š¥?•œ ?¬ê³? ?ˆ˜?Ÿ‰: 20ê°?
  , price NUMBER NOT NULL -- ? œ?’ˆ?Œë§¤ê?ê²? 
  , productdesc VARCHAR2(1000) -- ? œ?’ˆ?„¤ëª? 
  , youtubeurl VARCHAR2(300) -- ? œ?’ˆ ?œ ?Šœë¸? URL : ê´?? ¨ ?˜?ƒ ë§í¬
  , registerday DATE DEFAULT SYSDATE -- ë°œë§¤?¼
  , point NUMBER DEFAULT 10 -- ?¬?¸?Š¸ ? ?ˆ˜ : êµ¬ë§¤ ?‹œ ? ë¦? ?¬?¸?Š¸:10 ?¬?¸?Š¸
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

--ê³? ë¦¬ìŠ¤?Š¸
CREATE TABLE tbl_track (
    trackno        NUMBER        PRIMARY KEY,        -- ê³? ë²ˆí˜¸ (PK)
    fk_productno   NUMBER        NOT NULL,           -- ? œ?’ˆ ë²ˆí˜¸ (?•¨ë²? ë²ˆí˜¸, FK)
    track_order    NUMBER        NOT NULL,           -- ?•¨ë²? ?‚´ ê³? ?ˆœ?„œ 01, 02.....
    track_title    VARCHAR2(200) NOT NULL,           -- ê³? ? œëª?

    CONSTRAINT fk_track_product
      FOREIGN KEY (fk_productno)
      REFERENCES tbl_product(productno)              -- ? œ?’ˆ(?•¨ë²?) ?…Œ?´ë¸”ê³¼ ?—°ê²?
);

CREATE SEQUENCE seq_trackno
START WITH 1
INCREMENT BY 1
NOCACHE
NOCYCLE;

-- ì°? ?…Œ?´ë¸?
CREATE TABLE tbl_wishlist
(
    fk_userid  VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?””(FK) : tbl_member.userid ì°¸ì¡°

  , fk_productno NUMBER NOT NULL -- ? œ?’ˆë²ˆí˜¸(FK) : tbl_product.productno ì°¸ì¡°

  , CONSTRAINT PK_tbl_wishlist
        PRIMARY KEY (fk_userid, fk_productno) -- ë³µí•© ê¸°ë³¸?‚¤ : ?šŒ?›?•„?´?”” + ? œ?’ˆë²ˆí˜¸

  , CONSTRAINT FK_tbl_wishlist_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)

  , CONSTRAINT FK_tbl_wishlist_product
        FOREIGN KEY (fk_productno)
        REFERENCES tbl_product(productno)
);


-- ?¥ë°”êµ¬?‹ˆ ?…Œ?´ë¸?
CREATE TABLE tbl_cart
(
    cartno NUMBER -- ?¥ë°”êµ¬?‹ˆ ë²ˆí˜¸(PK)
  , fk_userid VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?””(FK) : tbl_member.userid ì°¸ì¡°
  , fk_productno NUMBER NOT NULL -- ? œ?’ˆë²ˆí˜¸(FK) : tbl_product.productno ì°¸ì¡°
  , qty NUMBER DEFAULT 1 NOT NULL -- ?ˆ˜?Ÿ‰ : ?¥ë°”êµ¬?‹ˆ?— ?‹´?? ? œ?’ˆ ?ˆ˜?Ÿ‰
  , CONSTRAINT PK_tbl_cart
        PRIMARY KEY (cartno)
  , CONSTRAINT FK_tbl_cart_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
  , CONSTRAINT FK_tbl_cart_product
        FOREIGN KEY (fk_productno)
        REFERENCES tbl_product(productno)
  , CONSTRAINT UQ_tbl_cart_user_product
        UNIQUE (fk_userid, fk_productno) -- ê°™ì? ?šŒ?›?´ ê°™ì? ? œ?’ˆ?„ ì¤‘ë³µ ?‹´ì§? ëª»í•˜?„ë¡? ? œ?•œ
);

CREATE SEQUENCE seq_cartno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;

-- ì£¼ë¬¸ ?…Œ?´ë¸?
CREATE TABLE tbl_order
(
    orderno NUMBER -- ì£¼ë¬¸ë²ˆí˜¸(PK) 
  , fk_userid VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?””(FK) : tbl_member.userid ì°¸ì¡°
  , totalprice NUMBER NOT NULL -- ì£¼ë¬¸ì´ì•¡ 
  , usepoint NUMBER DEFAULT 0 -- ?‚¬?š©?¬?¸?Š¸ : ì£¼ë¬¸ ?‹œ ?‚¬?š©?•œ ?¬?¸?Š¸
  , totalpoint NUMBER DEFAULT 0 -- ì£¼ë¬¸ì´? ?¬?¸?Š¸ : ì£¼ë¬¸?œ¼ë¡? ? ë¦½ëœ ?¬?¸?Š¸
  , orderdate DATE DEFAULT SYSDATE NOT NULL -- ì£¼ë¬¸?¼? 
  , postcode VARCHAR2(5) -- ?š°?¸ë²ˆí˜¸
  , address VARCHAR2(200) -- ì£¼ì†Œ
  , detailaddress VARCHAR2(200) -- ?ƒ?„¸ì£¼ì†Œ
  , extraaddress VARCHAR2(200) -- ì£¼ì†Œì°¸ê³ ?•­ëª?
  , deliverystatus VARCHAR2(20) DEFAULT 'ë°°ì†¡ì¤?ë¹„ì¤‘' -- ë°°ì†¡?ƒ?ƒœ : ë°°ì†¡ì¤?ë¹„ì¤‘ / ë°°ì†¡ì¤? / ë°°ì†¡?™„ë£?
  , ordercomment VARCHAR2(500) -- ì£¼ë¬¸ ë¬¸ì˜?‚´?š© : ì£¼ë¬¸ ê´?? ¨ ë¬¸ì˜ ?‚¬?•­
  , deliveryrequest VARCHAR2(500) -- ë°°ì†¡?‹œ ?š”ì²??‚¬?•­
  , CONSTRAINT PK_tbl_order
        PRIMARY KEY (orderno)
  , CONSTRAINT FK_tbl_order_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
 ,CONSTRAINT CK_tbl_order_deliverystatus
CHECK (deliverystatus IN ('ë°°ì†¡ì¤?ë¹„ì¤‘','ë°°ì†¡ì¤?','ë°°ì†¡?™„ë£?'))

);

CREATE SEQUENCE seq_orderno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;




-- ì£¼ë¬¸?ƒ?„¸ ?…Œ?´ë¸?
CREATE TABLE tbl_orderdetail
(
    orderdetailno NUMBER -- ì£¼ë¬¸?ƒ?„¸ ?¼? ¨ë²ˆí˜¸(PK)

  , fk_orderno NUMBER NOT NULL -- ì£¼ë¬¸ë²ˆí˜¸(FK) : tbl_order.orderno ì°¸ì¡°

  , fk_productno NUMBER NOT NULL -- ? œ?’ˆë²ˆí˜¸(FK) : tbl_product.productno ì°¸ì¡°

  , qty NUMBER NOT NULL -- ì£¼ë¬¸?Ÿ‰ 

  , unitprice NUMBER NOT NULL -- ì£¼ë¬¸?‹¨ê°? 

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

-- ? œ?’ˆêµ¬ë§¤?›„ê¸°ë¦¬ë·? ?…Œ?´ë¸?
CREATE TABLE tbl_review
(
    reviewno NUMBER -- ë¦¬ë·°ë²ˆí˜¸(PK)
  , fk_userid VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?””(FK) : tbl_member.userid ì°¸ì¡°
  , fk_productno NUMBER NOT NULL -- ? œ?’ˆë²ˆí˜¸(FK) : tbl_product.productno ì°¸ì¡°
  , rating NUMBER(1) NOT NULL -- ë³„ì  : 1 ~ 5 ? 
  , reviewcontent VARCHAR2(100) -- ë¦¬ë·°?‚´?š©
  , writedate DATE DEFAULT SYSDATE NOT NULL -- ?‘?„±?‚ ì§?
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


-- 1:1 ë¬¸ì˜ ?…Œ?´ë¸?
CREATE TABLE tbl_inquiry
(
    inquiryno NUMBER -- ë¬¸ì˜ë²ˆí˜¸(PK)
  , fk_userid VARCHAR2(40) NOT NULL -- ?šŒ?›?•„?´?””(FK) : tbl_member.userid ì°¸ì¡°
  , inquirycontent VARCHAR2(1000) NOT NULL -- ë¬¸ì˜?‚´?š©
  , inquirydate DATE DEFAULT SYSDATE NOT NULL -- ë¬¸ì˜ ?‘?„±?¼
  , inquirystatus VARCHAR2(10) DEFAULT '??ê¸?' NOT NULL -- ë¬¸ì˜?ƒ?ƒœ : ??ê¸? / ?™„ë£?
  , adminreply VARCHAR2(1000) -- ê´?ë¦¬ì?‹µë³?
  , replydate DATE -- ?‹µë³??¼
  , CONSTRAINT PK_tbl_inquiry
        PRIMARY KEY (inquiryno)
  , CONSTRAINT FK_tbl_inquiry_userid
        FOREIGN KEY (fk_userid)
        REFERENCES tbl_member(userid)
  , CONSTRAINT CK_tbl_inquiry_status
        CHECK (inquirystatus IN ('??ê¸?','?™„ë£?'))
);

CREATE SEQUENCE seq_inquiryno
START WITH 1
INCREMENT BY 1
NOMAXVALUE
NOMINVALUE
NOCYCLE
NOCACHE;


-- ê´?ë¦¬ì ?…Œ?´ë¸?
CREATE TABLE tbl_admin
(
    adminid VARCHAR2(40) -- ê´?ë¦¬ì ?•„?´?””(PK)
  , adminpwd VARCHAR2(200) NOT NULL -- ë¹„ë?ë²ˆí˜¸ : SHA-256 ?•”?˜¸?™” ???¥
  , CONSTRAINT PK_tbl_admin
        PRIMARY KEY (adminid)
);



SELECT P.productno, P.fk_categoryno, P.productname, P.productimg, P.price, P.productdesc, P.youtubeurl, P.point, P.stock, to_char(P.registerday, 'yyyy-mm-dd') AS registerday, 
       C.categoryname
FROM tbl_product P
JOIN tbl_category C ON P.fk_categoryno = C.categoryno
WHERE P.productno = 1;


SELECT trackno, fk_productno, track_order, track_title
FROM tbl_track
WHERE fk_productno = 20
ORDER BY track_order ASC;

select *
from tbl_product
where fk_categoryno = 1;