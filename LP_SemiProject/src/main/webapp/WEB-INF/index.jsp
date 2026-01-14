<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
 <link rel="stylesheet" href="<%= ctxPath%>/css/index.css">

  
  <!-- HEADER -->
<jsp:include page="header1.jsp"></jsp:include>

        <main>
      <section class="hero">
        <h1 class="headline">Press play,<br> analog way</h1>

        <div class="side">
          <p>
 			 A carefully curated vinyl collection,<br>
  				for modern music lovers who enjoy slow, intentional listening.
			</p>

         <button class="main-btn" id="btnShowAll" type="button">Show all Records</button>

        </div>
      </section>

      <section class="strip" aria-label="Showcase carousel">
        <!-- black semicircle accents (approximation) -->
       

        <div class="rail">
          <div class="track" id="track">
            <!-- 1 set (JS에서 복제해서 무한루프) -->
            <div class="card" style="--rot:-12deg">
              <img alt="" src="./images/main_1.jpeg">
            </div>

            <div class="card" style="--rot:10deg">
              <img alt="" src="./images/main_2.jpeg">
            </div>

            <div class="card" style="--rot:-8deg">
              <img alt="" src="https://images.unsplash.com/photo-1541961017774-22349e4a1262?auto=format&fit=crop&w=900&q=60">
            </div>

            <div class="badge" aria-label="15K lessons badge">
              <div style="text-align:center">
                <strong>VINYST</strong>
                <span>record</span>
              </div>
            </div>

            <div class="card" style="--rot:11deg">
              <img alt="" src="https://images.unsplash.com/photo-1541701494587-cb58502866ab?auto=format&fit=crop&w=900&q=60">
            </div>

            <div class="card" style="--rot:-10deg">
              <img alt="" src="<%= ctxPath%>/images/main_3.jpeg">
            </div>
          </div>
        </div>

        <div class="scrollhint">
          <span class="arr" aria-hidden="true">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <path d="M7 15l5 5 5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </span>

          <span>Scroll to see more</span>
          
		  <span class="arr" aria-hidden="true">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="none">
              <path d="M12 5v14" stroke="currentColor" stroke-width="2" stroke-linecap="round"/>
              <path d="M7 15l5 5 5-5" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"/>
            </svg>
          </span>

        </div>
	
      </section>
	  
		  	  <img class="main-line" src="<%= ctxPath%>/images/main_line.png" alt="">
	
    </main>


	
  <!-- 장르 바 (메인에서만 사용) -->
  <div class="genre-bar">
    <div class="genre-bar-inner">
      <button type="button" 
              class="${(empty requestScope.categoryNo or requestScope.categoryNo == 0) ? 'active' : ''}" 
              onclick="location.href='<%= ctxPath%>/index.lp?sort=${requestScope.sort}#product-list'">ALL</button>
      
      <button type="button" 
              class="${requestScope.categoryNo == 1 ? 'active' : ''}" 
              onclick="location.href='<%= ctxPath%>/index.lp?categoryno=1&sort=${requestScope.sort}#product-list'">POP</button>
      
      <button type="button" 
              class="${requestScope.categoryNo == 2 ? 'active' : ''}" 
              onclick="location.href='<%= ctxPath%>/index.lp?categoryno=2&sort=${requestScope.sort}#product-list'">ROCK</button>
      
      <button type="button" 
              class="${requestScope.categoryNo == 3 ? 'active' : ''}" 
              onclick="location.href='<%= ctxPath%>/index.lp?categoryno=3&sort=${requestScope.sort}#product-list'">JAZZ</button>
      
      <button type="button" 
              class="${requestScope.categoryNo == 4 ? 'active' : ''}" 
              onclick="location.href='<%= ctxPath%>/index.lp?categoryno=4&sort=${requestScope.sort}#product-list'">CLASSIC</button>
      
      <button type="button" 
              class="${requestScope.categoryNo == 5 ? 'active' : ''}" 
              onclick="location.href='<%= ctxPath%>/index.lp?categoryno=5&sort=${requestScope.sort}#product-list'">ETC</button>
    </div>
  </div>

 
<div class="main-search">
  <form class="main-search__form" role="search" action="<%= ctxPath%>/index.lp#product-list" method="get">
    <div class="main-search__field">
      <svg width="16" height="16" viewBox="0 0 24 24" fill="none" aria-hidden="true">
        <path d="M10.5 18a7.5 7.5 0 1 1 0-15 7.5 7.5 0 0 1 0 15Z"
              stroke="currentColor" stroke-width="2"/>
        <path d="M16.5 16.5 21 21"
              stroke="currentColor" stroke-width="2"
              stroke-linecap="round"/>
      </svg>

      <input type="search" name="q" value="${requestScope.searchWord}" placeholder="LP를 검색해보세요" aria-label="Search"/>
      
      <c:if test="${not empty requestScope.categoryNo and requestScope.categoryNo != 0}">
          <input type="hidden" name="categoryno" value="${requestScope.categoryNo}" />
      </c:if>
      <input type="hidden" name="sort" value="${requestScope.sort}" />
    </div>

    <button class="main-search__btn" type="submit">검색</button>
  </form>
</div>



<!-- ===== MAIN ===== -->

<div id="main-container">

<!-- 신곡 추천 -->
<section class="carousel">
  
 <div class="main-section-title">
  <h2>NEW</h2>
  <p>새로운 레코드를 만나보세요</p>
</div>


 
  <div class="carousel-wrapper">
    <button class="btn prev">‹</button>

    <div class="carousel-window">
      <div class="carousel-track">

		<c:if test="${not empty requestScope.newProductList}">
            <c:forEach var="np" items="${requestScope.newProductList}">
                <a class="carousel-item" href="<%= ctxPath%>/productdetail.lp?productno=${np.productno}">
                  <img src="<%= ctxPath%>${np.productimg}" alt="${np.productname}" />
                  
                  <div class="ci-text">
                    <p class="ci-name">${np.productname}</p>
                    <p class="ci-price">₩ <fmt:formatNumber value="${np.price}" pattern="#,###"/></p>
                  </div>
                </a>
            </c:forEach>
        </c:if>
	
      </div>
    </div>

    <button class="btn next">›</button>
  </div>
</section>

<section id="lp-container">
    <div class="lp-content">

      <div class="main-section-title">
        <h2>MUSIC FOR YOU</h2>
        <c:choose>
            <c:when test="${not empty sessionScope.loginuser}">
                <p>${sessionScope.loginuser.name}님의 취향을 분석하여 선별한 레코드입니다.</p>
            </c:when>
            <c:otherwise>
                <p>다양한 장르의 추천 레코드를 만나보세요.</p>
            </c:otherwise>
        </c:choose>
      </div>

      <div id="lpData" hidden>
         <c:if test="${not empty requestScope.recommendList}">
            <c:forEach var="item" items="${requestScope.recommendList}">
               <li class="lp-item"
                   data-album="${item.productname}"
                   data-emblem="￦ <fmt:formatNumber value='${item.price}' pattern='#,###'/>"
                   data-accent="#d0d0d0" 
                   data-img="<%= ctxPath%>${item.productimg}"
                   data-link="<%= ctxPath%>/productdetail.lp?productno=${item.productno}">
               </li>
            </c:forEach>
         </c:if>
         
         <c:if test="${empty requestScope.recommendList}">
            <li class="lp-item"
                data-album="Ready for Music"
                data-emblem="Vinyl Shop"
                data-accent="#9a9a9a"
                data-img="<%= ctxPath%>/images/logo.png"
                data-link="#">
            </li>
         </c:if>
      </div>

      <section>
        <div class="hero-img">
          <a class="quick-link" id="quickLink" href="#" target="_self" aria-label="바로가기">
            <span class="dot"></span>
            바로가기
          </a>
        </div>

        <div class="emblem-container">
          <div class="emblem text"></div>  
        </div>

        <h1 class="text">
          <span class="album-title"></span>
          <span class="LP-shop"></span>
        </h1>
      </section>

      <div class="button-container">
        <button class="scroll-left nav-arrow"><span></span>Prev</button>
        <button class="scroll-right nav-arrow">Next<span></span></button>
      </div>
      </div>
  </section>
 
 
  <!-- LP 상품 -->
  <section class="product-list">
	<div id="product-list" style="position:relative; top:-80px;"></div>
    <div class="main-section-title">
        <h2>STORE</h2>
        <p>다양한 레코드 상품들을 만나보세요.</p>
    </div>

    <div class="sort-bar">
        <select id="sortSelect" onchange="sortProduct()">
            <option value="latest"     ${requestScope.sort == 'latest'     ? 'selected' : ''}>최신순</option>
            <option value="rating"     ${requestScope.sort == 'rating'     ? 'selected' : ''}>별점순</option>
            <option value="price_low"  ${requestScope.sort == 'price_low'  ? 'selected' : ''}>가격 낮은순</option>
            <option value="price_high" ${requestScope.sort == 'price_high' ? 'selected' : ''}>가격 높은순</option>
        </select>
    </div>

	<script>
        function sortProduct() {
            const sortVal = document.getElementById("sortSelect").value;
            const categoryNo = "${requestScope.categoryNo}"; 
            const searchWord = "${requestScope.searchWord}";
            
            location.href = "<%= ctxPath%>/index.lp?categoryno=" + categoryNo + "&q=" + searchWord + "&sort=" + sortVal + "#product-list";
        }
    </script>
    
    <div class="grid">
        <c:if test="${not empty requestScope.productList}">
            <c:forEach var="p" items="${requestScope.productList}">
                <div class="product">
                    <a href="<%= ctxPath%>/productdetail.lp?productno=${p.productno}">
                        <img src="<%= ctxPath%>${p.productimg}" alt="${p.productname}">
                    </a>
                    <p class="main-product-name">${p.productname}</p>
                    <p class="price">
                        ₩ <fmt:formatNumber value="${p.price}" pattern="#,###"/>
                    </p>
                </div>
            </c:forEach>
        </c:if>
        
        <c:if test="${empty requestScope.productList}">
            <div style="width:100%; text-align:center; padding: 50px;">
                <script type="text/javascript">
                    alert("검색어에 해당하는 제품이 없습니다.");
                    
                    if (history.replaceState) {
                        var cleanUrl = window.location.protocol + "//" + window.location.host + window.location.pathname + window.location.search;
                        window.history.replaceState({path:cleanUrl}, '', cleanUrl);
                    }

                    var searchInput = document.querySelector("input[name='q']");
                    if(searchInput) {
                        searchInput.focus();
                        searchInput.select();
                    }
                </script>
                등록된 상품이 없습니다.
            </div>
        </c:if>
    </div>

    <div class="pagebar">
        <ul class="pagination" style="margin:0; list-style:none; display:flex; justify-content:center; padding:0;">
            ${requestScope.pageBar}
        </ul>
    </div>
    
</section>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
	header {
    position: relative; /* z-index가 작동하려면 필요 (원래 헤더가 fixed면 fixed로 변경) */
    z-index: 999999 !important; /* 팝업보다 무조건 높게 설정 */
	}
    /* 팝업 공통 스타일 */
    .main-popup {
        position: absolute;
        top: 50%;
        left: 50%;
        width: 380px;
        max-width: 90vw; /* 모바일 대응 */
        background-color: #fff;
        border-radius: 12px; /* 둥근 모서리 */
        box-shadow: 0 15px 40px rgba(0,0,0,0.18); /* 부드럽고 깊은 그림자 */
        display: none; 
        font-family: 'Pretendard', sans-serif;
        z-index: 9999;
        overflow: hidden; /* 내부 요소가 둥근 모서리 넘지 않게 */
        animation: popupFadeIn 0.4s ease-out; /* 등장 애니메이션 */
    }

    @keyframes popupFadeIn {
        from { opacity: 0; transform: translate(-50%, -45%); }
        to { opacity: 1; transform: translate(-50%, -50%); }
    }

    /* 팝업 내용 영역 */
    .popup-content {
        padding: 32px 24px 24px;
        text-align: center;
        color: #2a2a2a;
    }

    /* 앨범 이미지 스타일 */
    .popup-album-img {
        width: 180px;
        height: 180px;
        object-fit: cover;
        margin: 0 auto 20px;
        display: block;
        border-radius: 6px;
        box-shadow: 0 8px 20px rgba(0,0,0,0.15); /* 앨범 그림자 */
    }

    /* 아이콘 스타일 (배송지연) */
    .popup-icon-wrapper {
        width: 60px;
        height: 60px;
        background: #f8d7da; /* 연한 빨강 배경 */
        color: #d32f2f;
        border-radius: 50%;
        display: flex;
        align-items: center;
        justify-content: center;
        margin: 0 auto 16px;
        font-size: 24px;
    }

    /* 타이틀 */
    .popup-header {
        font-size: 20px;
        font-weight: 800;
        margin-bottom: 12px;
        letter-spacing: -0.5px;
        color: #111;
    }
    
    /* 설명 텍스트 */
    .popup-desc {
        font-size: 15px;
        color: #666;
        line-height: 1.6;
        margin-bottom: 0;
        word-break: keep-all;
    }

    /* 하단 버튼 영역 */
    .popup-footer {
        background-color: #f9f9f9;
        padding: 14px 20px;
        display: flex;
        justify-content: space-between;
        align-items: center;
        border-top: 1px solid #eee;
    }

    /* 버튼 스타일 */
    .btn-close-today {
        font-size: 13px;
        color: #888;
        cursor: pointer;
        transition: color 0.2s;
        background: none;
        border: none;
        padding: 0;
    }
    .btn-close-today:hover { color: #555; text-decoration: underline; }

    .btn-close {
        font-size: 14px;
        color: #222;
        font-weight: 700;
        cursor: pointer;
        background: none;
        border: none;
        padding: 0;
        transition: opacity 0.2s;
    }
    .btn-close:hover { opacity: 0.7; }

    /* 겹침 처리 & 위치 미세 조정 */
    #popup_delivery {
        z-index: 10000; 
        transform: translate(-52%, -52%); /* 살짝 왼쪽 위 */
    }

    #popup_album {
        z-index: 9999; 
        transform: translate(-48%, -48%); /* 살짝 오른쪽 아래 */
    }
</style>

<div id="popup_delivery" class="main-popup">
    <div class="popup-content">
        <div class="popup-icon-wrapper">
            <i class="fa-solid fa-truck"></i>
        </div>
        
        <div class="popup-header">
            배송 지연 안내
        </div>
        
        <p class="popup-desc">
            주문량 급증으로 인해 배송이<br>
            평소보다 <strong>2~3일 지연</strong>되고 있습니다.<br>
            양해 부탁드립니다.
        </p>
    </div>
    
    <div class="popup-footer">
        <button type="button" class="btn-close-today" onclick="closePopupToday('popup_delivery')">오늘 하루 보지 않기</button>
        <button type="button" class="btn-close" onclick="closePopup('popup_delivery')">닫기</button>
    </div>
</div>

<div id="popup_album" class="main-popup">
    <div class="popup-content">
        <img src="<%= ctxPath%>/images/productimg/75.png" alt="New Album" class="popup-album-img">

        <div class="popup-header">
            NEW ALBUM
        </div>
        
        <p class="popup-desc">
            <strong>Moby - Reprise</strong><br>
            기다리시던 한정판 바이닐이 입고되었습니다.<br>
            품절되기 전에 만나보세요.
        </p>
    </div>

    <div class="popup-footer">
        <button type="button" class="btn-close-today" onclick="closePopupToday('popup_album')">오늘 하루 보지 않기</button>
        <button type="button" class="btn-close" onclick="closePopup('popup_album')">닫기</button>
    </div>
</div>

<script type="text/javascript">
    $(document).ready(function(){
        // 페이지 로드 시 쿠키 확인
        checkPopupCookie('popup_delivery');
        checkPopupCookie('popup_album');
    });

    function checkPopupCookie(popupId) {
        if (getCookie(popupId) != "done") {
            $("#" + popupId).fadeIn(300); // 부드럽게 등장
        }
    }

    function closePopup(popupId) {
        $("#" + popupId).fadeOut(200);
    }

    function closePopupToday(popupId) {
        setCookie(popupId, "done", 1); 
        $("#" + popupId).fadeOut(200);
    }

    function setCookie(name, value, expiredays) {
        var todayDate = new Date();
        todayDate.setDate(todayDate.getDate() + expiredays); 
        document.cookie = name + "=" + escape(value) + "; path=/; expires=" + todayDate.toGMTString() + ";";
    }

    function getCookie(name) {
        var nameOfCookie = name + "=";
        var x = 0;
        while (x <= document.cookie.length) {
            var y = (x + nameOfCookie.length);
            if (document.cookie.substring(x, y) == nameOfCookie) {
                if ((endOfCookie = document.cookie.indexOf(";", y)) == -1)
                    endOfCookie = document.cookie.length;
                return unescape(document.cookie.substring(y, endOfCookie));
            }
            x = document.cookie.indexOf(" ", x) + 1;
            if (x == 0) break;
        }
        return "";
    }
</script>

</div>

  <!-- footer -->
 <jsp:include page="footer1.jsp"></jsp:include>
  
<!-- 캐러셀 JS -->
<script src="<%= ctxPath%>/js/carousel.js"></script>

<script src="<%= ctxPath%>/js/index.js"></script>


