<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_inquiry_list.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_order.css">

<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<main class="mypage-wrapper">
  <div class="mypage-container">

    <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath%>/my_info/my_info.lp">프로필 수정</a>
      <a href="<%= ctxPath%>/my_info/my_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/my_info/my_wish.lp">찜내역</a>
      <a href="<%= ctxPath%>/my_info/my_order.lp" class="active">구매내역</a>
      <a href="<%= ctxPath%>/my_info/my_taste.lp">취향선택</a>
    </aside>

    <section class="mypage-content">
      <h2>구매내역</h2>

      <div class="order-list">

        <div class="order-card">
          <div class="order-summary">

            <div class="order-product">
              <img src="../images/지수.png" alt="대표 상품">
              <div class="product-info">
                <p class="name">
                  상품명 : 로제 LP
                  <span class="more-count">외 2건</span>
                </p>
                <p class="meta">총 수량 : 3개</p>
                <p class="price">총 가격 : 500,000원</p>
              </div>
            </div>

            <div class="order-point">
              <span>적립포인트: 30p</span>
              <button class="btn-toggle" type="button" onclick="toggleOrderDetails(this)">
                펼치기 ▼
              </button>
            </div>

            <div class="order-status">
              <p class="date">2025.01.10</p>
              <p class="status-text">배송완료</p>

              <!-- 배송완료가 되었을 시 송장번호 확인 팝업 버튼 -->
              
	              <button class="btn-toggle"
                		type="button"
                		onclick="openTrackingPopup(this)">
                		송장번호 확인하러가기
            		</button>
        		 
            </div>

          </div>

		<!-- 주문자 정보 및 상품 -->
          <div class="order-details" aria-hidden="true">
            <div class="detail-list">

              <div class="order-shipping">
                <h4>배송 정보</h4>
                <p class="receiver">받는 사람: 홍길동</p>
                <p class="address">
                  우편번호:121212<br>
                  주소: 서울시 강남구 테헤란로 123, 101동 202호
                </p>
              </div>
              
			<!-- 상품 -->
              <div class="detail-item">
                <img src="../images/지수.png" alt="상품">
                <div class="detail-info">
                  <p class="d-name">로제 LP</p>
                  <p class="d-sub">수량: 1개</p>
                </div>
                <div class="detail-actions">
                  <div class="detail-price">300,000원</div>
                  <button
                    class="btn-review"
                    type="button"
                    onclick="openReviewPopup('ORD001','PRD001','로제 LP')">
                    리뷰쓰기
                  </button>
                </div>
              </div>

            </div>
          </div>
        </div>
        
        

		<!-- 페이징바 -->
        <div class="pagebar">
          <button class="page-btn prev" disabled><i class="fa-solid fa-chevron-left"></i></button>
          <button class="page-num active">1</button>
          <button class="page-num">2</button>
          <button class="page-num">3</button>
          <button class="page-num">4</button>
          <button class="page-btn next"><i class="fa-solid fa-chevron-right"></i></button>
        </div>

      </div>
    </section>
  </div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/my_info/my_order.js"></script>

<script type="text/javascript">
  
  

  
</script>
