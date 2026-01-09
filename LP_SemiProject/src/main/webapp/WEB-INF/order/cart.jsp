<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%
  String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%= ctxPath%>/css/order/cart.css">
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<main class="cart-wrapper">
  <div class="cart-container">

    <section class="cart-items">

      <div class="cart-header">
        <label>
          <input type="checkbox" id="checkAll">
          전체선택
        </label>
      </div>

      <c:if test="${empty cartList}">
        <div style="padding:20px;">장바구니가 비어있습니다.</div>
      </c:if>

      <c:forEach var="dto" items="${cartList}">
        <div class="cart-item">
          <input type="checkbox" class="chkItem" value="${dto.cartno}">

          <img src="<%= ctxPath%>${dto.productimg}" alt="${dto.productname}">

          <div class="item-info">
            <p class="item-name">${dto.productname}</p>
            <span class="item-point">수량: ${dto.qty}개</span>

            <div class="item-meta">
              <p class="item-price">
                ₩ <fmt:formatNumber value="${dto.totalPrice}" pattern="#,###"/>
              </p>

              <p class="item-point">적립 <span>${dto.totalPoint}P</span></p>
            </div>
          </div>

          <div class="qty-box">
            
           <form method="get" action="<%= ctxPath %>/productdetail.lp" style="display:inline;">
			  <input type="hidden" name="productno" value="${dto.productno}">
			  <input type="hidden" name="cartno" value="${dto.cartno}">
			  <button type="submit" class="qty-btn">수정하기</button>
			</form>





          </div>
        </div>
      </c:forEach>

      <div class="cart-actions">
      <form id="cartDeleteForm" >
        <button type="button" id="btnDeleteSelected">선택상품 삭제</button>
        <button type="button" class="danger" id="btnDeleteAll">전체삭제</button>
      </div>
	 </form>
	
    </section>

    <section class="summary-card">
      <h3>결제 정보</h3>

      <div class="summary-row">
        <span>주문금액</span>
        <span>₩ <fmt:formatNumber value="${sumTotalPrice}" pattern="#,###"/></span>
      </div>

      <div class="summary-row">
        <span>할인금액</span>
        <span>- ₩ 0</span>
      </div>

      <div class="summary-row">
        <span>배송비</span>
        <span>₩ <fmt:formatNumber value="3000" pattern="#,###"/></span>
      </div>

      <hr>

      <div class="summary-row total">
        <span>총 결제금액</span>
        <span>₩ <fmt:formatNumber value="${sumTotalPrice + 3000}" pattern="#,###"/></span>
      </div>

      <div class="summary-row point">
        <span>적립 포인트</span>
        <span><fmt:formatNumber value="${sumTotalPoint}" pattern="#,###"/>P</span>
      </div>

      <div class="action-buttons">
        <button class="cart" onclick="location.href='<%= ctxPath%>/index.lp'">쇼핑 계속하기</button>
        
         <form id="goBuyForm" method="post" action="<%= ctxPath %>/order/buy.lp">
	  		<!-- JS로 체크된 cartno들을 hidden으로 추가 -->
	  		<button type="submit" class="buy">주문자 정보 입력하러 가기</button>
		</form>
      </div>
    </section>

  </div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />
<script src="<%= ctxPath%>/js/order/cart.js"></script>


