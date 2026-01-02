<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
  <!-- CSS -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/order/cart.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
  <!-- MAIN -->
<main class="cart-wrapper">
  <div class="cart-container">

<!-- 왼쪽: 장바구니 상품 -->
<section class="cart-items">

  <div class="cart-header">
    <label>
      <input type="checkbox">
      전체선택
    </label>
  </div>

 
<!-- 상품 1 -->
<div class="cart-item">
  <input type="checkbox">

  <img src="<%= ctxPath%>/images/리사.png" alt="리사 LP">

  <div class="item-info">
    <p class="item-name">리사 LP</p>
   	<span class="item-point">수량: 1개</span>

    <div class="item-meta">
      <p class="item-price">₩ 42,000</p>
      
      <p class="item-point">적립 <span>10P</span></p>
    </div>
  </div>


</div>



  <!-- 하단 버튼 -->
  <div class="cart-actions">
    <button>선택상품 삭제</button>
    <button class="danger">전체삭제</button>
  </div>

</section>

<!-- 오른쪽: 결제 요약 -->
<section class="summary-card">

  <h3>결제 정보</h3>

  <div class="summary-row">
    <span>주문금액</span>
    <span>₩ 82,000</span>
  </div>

  <div class="summary-row">
    <span>할인금액</span>
    <span>- ₩ 5,000</span>
  </div>

  <div class="summary-row">
    <span>배송비</span>
    <span>₩ 3,000</span>
  </div>

  <hr>

  <div class="summary-row total">
    <span>총 결제금액</span>
    <span>₩ 80,000</span>
  </div>

  <div class="summary-row point">
    <span>적립 포인트</span>
    <span>800P</span>
  </div>

  <div class="action-buttons">
    <button class="cart" onclick="location.href='<%= ctxPath%>/index.lp'">
      더 담으러가기
    </button>
    <button class="buy" onclick="location.href='<%= ctxPath%>/order/buy.lp'">
      구매하기
    </button>
  </div>

</section>


  </div>
</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />