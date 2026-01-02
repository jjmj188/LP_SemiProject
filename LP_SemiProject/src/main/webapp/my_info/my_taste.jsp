<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
   <!-- 마이페이지 공통 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">

  <!-- 취향 선택 전용 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_taste.css">
    
	<!-- HEADER -->
	<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
    
    <!-- MAIN -->
<main class="mypage-wrapper">
  <div class="mypage-container">

    <!-- 왼쪽 메뉴 -->
    <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath%>/WEB-INF/my_info.html">프로필 수정</a>
      <a href="<%= ctxPath%>/WEB-INF/my_info/my_inquiry.jsp">문의내역</a>
      <a href="<%= ctxPath%>/WEB-INF/my_info/my_wish.jsp" >찜내역</a>
      <a href="<%= ctxPath%>/WEB-INF/my_info/my_order.jsp">구매내역</a>
      <a href="<%= ctxPath%>/WEB-INF/my_info/my_taste.jsp" class="active">취향선택</a>
    </aside>

    <!-- 오른쪽 콘텐츠 -->
    <section class="mypage-content">
      <h2>취향선택</h2>
      <p class="taste-desc">좋아하는 음악 장르를 선택해주세요 (복수 선택 가능)</p>

      <!-- 취향 선택 영역 -->
      <div class="taste-grid">

        <div class="taste-item" data-value="pop">
          <div class="img-wrap">
            <img src="<%= ctxPath%>/images/라쿠나.png" alt="POP">
          </div>
          <div class="taste-label">POP</div>
        </div>

        <div class="taste-item" data-value="rock">
          <div class="img-wrap">
            <img src="<%= ctxPath%>/images//로제.png" alt="ROCK">
          </div>
          <div class="taste-label">ROCK</div>
        </div>

        <div class="taste-item" data-value="jazz">
          <div class="img-wrap">
            <img src="<%= ctxPath%>/images/데몬헌터스.png" alt="JAZZ">
          </div>
          <div class="taste-label">JAZZ</div>
        </div>

        <div class="taste-item" data-value="classic">
          <div class="img-wrap">
            <img src="<%= ctxPath%>/images/지수.png" alt="CLASSIC">
          </div>
          <div class="taste-label">CLASSIC</div>
        </div>

        <div class="taste-item" data-value="kpop">
          <div class="img-wrap">
            <img src="<%= ctxPath%>/images/도영.png" alt="K-POP">
          </div>
          <div class="taste-label">K-POP</div>
        </div>

      </div>

      <!-- 하단 버튼 -->
      <div class="taste-bottom">
        <button type="button" class="btn-save">수정하기</button>
      </div>
    </section>

  </div>
</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/my_info/my_taste.js"></script>