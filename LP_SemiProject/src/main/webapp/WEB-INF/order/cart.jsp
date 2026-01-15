<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
  String ctxPath = request.getContextPath();
%>

<meta name="ctxPath" content="<%= ctxPath %>" />

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
          <input type="checkbox"
                 class="chkItem"
                 value="${dto.cartno}"
                 data-price="${dto.totalPrice}"
                 data-point="${dto.totalPoint}">

          <%-- [수정] 이미지 경로 정규화 로직 적용 --%>
          <c:set var="simpleFileName" value="${dto.productimg}" />
          <c:if test="${fn:contains(simpleFileName, 'images')}">
              <c:set var="simpleFileName" value="${fn:replace(simpleFileName, '/images/productimg/', '')}" />
              <c:set var="simpleFileName" value="${fn:replace(simpleFileName, 'images/productimg/', '')}" />
          </c:if>
          
          <%-- 정제된 파일명에 표준 경로 적용 --%>
          <img src="<%= ctxPath%>/images/productimg/${simpleFileName}" alt="${dto.productname}">
          <%-- [수정 끝] --%>

          <div class="item-info">
            <p class="item-name">${dto.productname}</p>
            <span class="item-point">수량: ${dto.qty}개</span>

            <div class="item-meta">
              <p class="item-price">
                ₩ <fmt:formatNumber value="${dto.totalPrice}" pattern="#,###"/>
              </p>

              <p class="item-point">적립 <span><fmt:formatNumber value="${dto.totalPoint}" pattern="#,###"/>P</span></p>
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

      <form id="cartDeleteForm">
        <div class="cart-actions">
          <button type="button" id="btnDeleteSelected">선택상품 삭제</button>
          <button type="button" class="danger" id="btnDeleteAll">전체삭제</button>
        </div>
      </form>

    </section>

    <section class="summary-card">
      <h3>결제 정보</h3>

      <div class="summary-row">
        <span>주문금액</span>
        <span>₩ <span id="sumPrice">0</span></span>
      </div>

      <div class="summary-row">
        <span>배송비</span>
        <span>₩ <span id="shipFee">0</span></span>
      </div>

      <hr>

      <div class="summary-row total">
        <span>총 결제금액</span>
        <span>₩ <span id="payTotal">0</span></span>
      </div>

      <div class="summary-row point">
        <span>적립 포인트</span>
        <span><span id="sumPoint">0</span>P</span>
      </div>

      <div class="action-buttons">
        <button type="button" class="cart" onclick="location.href='<%= ctxPath%>/index.lp'">쇼핑 계속하기</button>

        <form id="goBuyForm" method="post" action="<%= ctxPath %>/order/buy.lp">
          <button type="submit" class="buy">주문자 정보 입력하러 가기</button>
        </form>
      </div>
    </section>

  </div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="<%= ctxPath%>/js/order/cart.js"></script>