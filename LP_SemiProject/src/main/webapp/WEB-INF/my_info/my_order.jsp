<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
 <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">

  <!-- 구매내역 전용 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_inquiry_list.css">

  <!-- 구매내역 css-->
   <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_order.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
 
  
  <!-- MAIN -->
  <main class="mypage-wrapper">
    <div class="mypage-container">

      <!-- 왼쪽 메뉴 -->
     <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath%>/my_info/my_info.lp">프로필 수정</a>
      <a href="<%= ctxPath%>/my_info/my_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/my_info/my_wish.lp" >찜내역</a>
      <a href="<%= ctxPath%>/my_info/my_order.lp" class="active">구매내역</a>
      <a href="<%= ctxPath%>/my_info/my_taste.lp" >취향선택</a>
    </aside>

      <!-- 오른쪽 콘텐츠 -->
      <section class="mypage-content">
        <h2>구매내역</h2>

        <div class="order-list">

          <!-- ====== 주문 1 ====== -->
          <div class="order-card" data-order-id="ORD001">
            <div class="order-summary">

              <!-- 대표 상품 -->
              <div class="order-product">
                <img src="../images/지수.png" alt="대표 상품">
                <div class="product-info">
                  <p class="name">
                    상품명 : 로제 LP
                    <span class="more-count">외 2건</span>
                  </p>
                  <!-- ✅ 상단은 총 수량/총 가격으로(요청대로) -->
                  <p class="meta">총 수량 : 3개</p>
                  <p class="price">총 가격 : 500,000원</p>
                </div>
              </div>

              <!-- 적립포인트 + 펼치기(리뷰쓰기 제거) -->
              <div class="order-point">
                <span>적립포인트: 30p</span>
                <button class="btn-toggle" type="button" onclick="toggleOrderDetails(this)">
                  펼치기 ▼
                </button>
              </div>

              <!-- 주문 상태 -->
              <div class="order-status">
                <p class="date">2025.01.10</p>
                <p>배송완료</p>
              </div>

            </div>

            <!-- 펼침 영역(같은 주문의 전체 상품들) -->
            <div class="order-details" aria-hidden="true">
              <div class="detail-list">

                <div class="detail-item">
                  <img src="../images/지수.png" alt="상품">
                  <div class="detail-info">
                    <p class="d-name">로제 LP</p>
                    <p class="d-sub">수량: 1개</p>
                  </div>

                  <div class="detail-actions">
                    <div class="detail-price">300,000원</div>
                    <!-- ✅ 상품별 리뷰쓰기 버튼 -->
                    <button
                      class="btn-review"
                      type="button"
                      onclick="openReviewPopup('ORD001','PRD001','로제 LP')">
                      리뷰쓰기
                    </button>
                  </div>
                </div>

                <div class="detail-item">
                  <img src="../images/지수.png" alt="상품">
                  <div class="detail-info">
                    <p class="d-name">지수 LP</p>
                    <p class="d-sub">수량: 2개</p>
                  </div>

                  <div class="detail-actions">
                    <div class="detail-price">120,000원</div>
                    <button
                      class="btn-review"
                      type="button"
                      onclick="openReviewPopup('ORD001','PRD002','지수 LP')">
                      리뷰쓰기
                    </button>
                  </div>
                </div>

                <div class="detail-item">
                  <img src="../images/지수.png" alt="상품">
                  <div class="detail-info">
                    <p class="d-name">리사 LP</p>
                    <p class="d-sub">수량: 1개</p>
                  </div>

                  <div class="detail-actions">
                    <div class="detail-price">80,000원</div>
                    <button
                      class="btn-review"
                      type="button"
                      onclick="openReviewPopup('ORD001','PRD003','리사 LP')">
                      리뷰쓰기
                    </button>
                  </div>
                </div>
				    	<!-- 배송 정보 -->
					<div class="order-shipping">
					  <h4>배송 정보</h4>
					  <p class="receiver">받는 사람: 홍길동</p>
					  <p class="address">
					    주소: 서울시 강남구 테헤란로 123, 101동 202호
					  </p>
					</div>
              </div>

           	       
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


        </div>
      </section>
    </div>
  </main>
<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/my_info/my_order.js"></script>
