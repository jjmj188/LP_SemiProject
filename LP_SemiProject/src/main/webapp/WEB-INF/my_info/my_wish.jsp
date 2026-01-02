<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>

   <!-- 마이페이지 공통 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">

  <!-- 찜내역 전용 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_wish.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
  <main class="mypage-wrapper">
  <div class="mypage-container">

    <!-- 왼쪽 사이드바 -->
    <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath%>/my_info/my_info.lp">프로필 수정</a>
      <a href="<%= ctxPath%>/my_info/my_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/my_info/my_wish.lp" class="active">찜내역</a>
      <a href="<%= ctxPath%>/my_info/my_order.lp">구매내역</a>
      <a href="<%= ctxPath%>/my_info/my_taste.lp" >취향선택</a>
    </aside>

    <!-- 오른쪽 컨텐츠 -->
    <section class="mypage-content">
      <h2>찜내역</h2>

      <div class="wish-list">

        <!-- item -->
        <div class="wish-item">
          <div class="wish-img">
            <img src="<%= ctxPath%>/images/릴피쉬.png" alt="ROSÉ LP">
             <button type="button" id="wishBtn"  class="wish-heart active" onclick="toggleWish()">
            <i class="fa-solid fa-heart"></i> 
             </button>
          </div>
          <p class="wish-title">ROSÉ LP</p>
        </div>
        <div class="wish-item">
          <div class="wish-img">
            <img src="<%= ctxPath%>/images/릴피쉬.png" alt="ROSÉ LP">
             <button type="button" id="wishBtn"  class="wish-heart active" onclick="toggleWish()">
            <i class="fa-solid fa-heart"></i> 
             </button>
          </div>
          <p class="wish-title">ROSÉ LP</p>
        </div>
        <div class="wish-item">
          <div class="wish-img">
            <img src="<%= ctxPath%>/images/릴피쉬.png" alt="ROSÉ LP">
             <button type="button" id="wishBtn"  class="wish-heart active" onclick="toggleWish()">
            <i class="fa-solid fa-heart"></i> 
             </button>
          </div>
          <p class="wish-title">ROSÉ LP</p>
        </div>
        
      </div>


       <!-- 페이징 영역 -->
<div class="pagebar">
  <button class="page-btn prev" disabled>
    <i class="fa-solid fa-chevron-left"></i>
  </button>

  <button class="page-num active">1</button>
  <button class="page-num">2</button>
  <button class="page-num">3</button>
  <button class="page-num">4</button>

  <button class="page-btn next">
    <i class="fa-solid fa-chevron-right"></i>
  </button>
</div>

    </section>

  </div>
</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/my_info/my_wish.js"></script>