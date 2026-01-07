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

<c:if test="${not empty sessionScope.loginuser}">
  <!-- 취향 추천 -->
  <section id="lp-container">
	<div class="lp-content">

 	<div class="main-section-title">
   <h2>MUSIC FOR YOU</h2>
	<p>양소라님의 취향에 맞춰 선별한 레코드입니다.</p>
	</div>

		 <div id="lpData" hidden>
    <!--
      DB로 바꿀 땐 이 li를 반복 출력.
      최대 4개정도..?
    -->
	  
		<li class="lp-item"
        data-album="Pink Floyd - The Dark Side of the Moon"
        data-emblem="legendary progressive rock"
        data-accent="#9a9a9a"
        data-img="<%= ctxPath%>/images/김마리.jpg"
        data-link="../product/detail.html?productno=1">
      
    </li>

    <li class="lp-item"
        data-album="Pink Floyd - The Dark Side of the Moon"
        data-emblem="legendary progressive rock"
        data-accent="#9a9a9a"
        data-img="<%= ctxPath%>/images/김마리.jpg"
        data-link="../product/detail.html?productno=1">
      
    </li>

  </div>

  <section>
    <div class="hero-img">
      <a class="quick-link" id="quickLink" href="<%= ctxPath%>" target="_self" aria-label="바로가기"> <!--/product_detail.jsp?productno= 로 이동-->
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
</c:if>
 
 
  <!-- LP 상품 -->
  <section class="product-list" id="product-list">

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
                등록된 상품이 없습니다.
            </div>
        </c:if>
    </div>

    <div class="pagination">
        <c:if test="${requestScope.totalPage > 0}">
            <c:forEach var="i" begin="1" end="${requestScope.totalPage}">
                <c:choose>
                    <c:when test="${i == requestScope.currentPage}">
                        <a class="active">${i}</a> 
                    </c:when>
                    <c:otherwise>
                        <a href="<%= ctxPath%>/index.lp?pageNo=${i}&categoryno=${requestScope.categoryNo}&q=${requestScope.searchWord}&sort=${requestScope.sort}#product-list">${i}</a>
                    </c:otherwise>
                </c:choose>
            </c:forEach>
        </c:if>
    </div>
    
</section>


</div>

  <!-- footer -->
 <jsp:include page="footer1.jsp"></jsp:include>
  
<!-- 캐러셀 JS -->
<script src="<%= ctxPath%>/js/carousel.js"></script>

<script src="<%= ctxPath%>/js/index.js"></script>

