<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<!-- 다음 주소 API -->
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="<%= ctxPath %>/13_daum_address_search/js/daum_address_search.js"></script>

<!-- (주의) jQuery 중복 로드면 문제 생길 수 있음. 가능하면 하나만 쓰는 게 맞다 -->
<script src="https://code.jquery.com/jquery-1.12.4.min.js"></script>
<script src="https://service.iamport.kr/js/iamport.payment-1.1.2.js"></script>

<link rel="stylesheet" href="<%= ctxPath%>/css/order/buy.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/order/cart.css">

<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<main class="buy-wrapper">
  <div class="buy-container">

    <!-- ================= LEFT ================= -->
    <section class="buy-left">
      <div class="buy-card">
        <h3>주문자 / 배송 정보</h3>

        <div class="form-group">
          <label>주문자 이름</label>
          <input type="text" placeholder="이름 입력" value="${sessionScope.loginuser.name}" readonly>
        </div>

        <div class="form-group">
          <label>연락처</label>
          <div class="hp-row">
              <input type="text" value="010" readonly> -
              <input type="text" name="hp2" id="hp2" maxlength="4" value="${fn:substring(sessionScope.loginuser.mobile,3,7)}" readonly> -
              <input type="text" name="hp3" id="hp3" maxlength="4" value="${fn:substring(sessionScope.loginuser.mobile,7,11)}" readonly>
          </div>
        </div>

        <div class="form-group">
          <label>이메일</label>
          <input type="email" placeholder="email@example.com" value="${sessionScope.loginuser.email}" readonly>
        </div>

        <hr>

        <!-- 포인트 -->
        <div class="form-group">
          <label class="title">포인트 사용</label>
          <input type="text" class="point-input" value="0 P" id="pointInput"
                 data-max-point="${sessionScope.loginuser.point}">

          <div class="point-check-row">
            <label>
              <input type="checkbox" id="chkUseAllPoint">
              포인트 전부 사용하기
            </label>
          </div>
        </div>

        <hr>

        <!-- 주소 -->
        <div class="form-group">
          <label>주소</label>

          <div class="address-row">
            <input type="text" id="postcode" name="postcode" placeholder="우편번호" readonly
                   value="${sessionScope.loginuser.postcode}">

            <button type="button" class="btn-outline" onclick="openDaumPOST()">
              우편번호 찾기
            </button>
          </div>

          <input type="text" id="address" name="address" class="form-group" placeholder="도로명 주소" readonly
                 value="${sessionScope.loginuser.address}">

          <input type="text" id="detailAddress" name="detailaddress" class="form-group" placeholder="상세 주소"
                 value="${sessionScope.loginuser.detailaddress}">

          <input type="text" id="extraAddress" name="extraaddress" class="form-group" placeholder="참고 항목"
                 value="${sessionScope.loginuser.extraaddress}">
        </div>

        <!-- 요청사항 -->
        <div class="form-group">
          <label>배송 요청사항</label>
          <select id="requestSelect">
            <option value="">선택해주세요</option>
            <option value="문 앞에 놓아주세요">문 앞에 놓아주세요</option>
            <option value="경비실에 맡겨주세요">경비실에 맡겨주세요</option>
            <option value="배송 전 연락주세요">배송 전 연락주세요</option>
            <option value="직접 입력">직접 입력</option>
          </select>
        </div>

        <div class="form-group">
          <textarea id="requestText" placeholder="배송 요청사항을 입력하세요"></textarea>
        </div>

        <div class="save-box">
          <label>
            <input type="checkbox">
            주소 및 주문자 정보 저장하기
          </label>
        </div>

      </div>
    </section>

    <!-- ================= RIGHT ================= -->
    <aside class="buy-right">
      <section class="summary-card">
        <h3>결제 정보</h3>

        <div class="summary-row">
          <span>주문금액</span>
          <span>₩ <fmt:formatNumber value="${sumTotalPrice}" pattern="#,###"/></span>
        </div>

        <div class="summary-row">
          <span>할인금액</span>
          <span>- ₩ <fmt:formatNumber value="${discountAmount}" pattern="#,###"/></span>
        </div>

        <div class="summary-row">
          <span>배송비</span>
          <span>₩ <fmt:formatNumber value="${deliveryFee}" pattern="#,###"/></span>
        </div>

        <hr>

        <div class="summary-row total">
          <span>총 결제금액</span>
          <span>₩ <fmt:formatNumber value="${finalPayAmount}" pattern="#,###"/></span>
        </div>

        <div class="summary-row point">
          <span>적립 포인트</span>
          <span><fmt:formatNumber value="${sumTotalPoint}" pattern="#,###"/>P</span>
        </div>

        <div class="action-buttons">
          <button class="cart" onclick="location.href='<%= ctxPath%>/order/cart.lp'">
            더 담으러가기
          </button>
          <button type="button" class="buy" id="btnBuy">구매하기</button>
        </div>
      </section>

      <c:forEach var="cno" items="${cartnoArr}">
        <input type="hidden" class="selectedCartno" value="${cno}">
      </c:forEach>

      <input type="hidden" id="ctxPath" value="<%=ctxPath%>">

      <!-- sumTotalPrice: 상품합계 -->
      <input type="hidden" id="sumTotalPrice" value="${sumTotalPrice}">

      <!-- 배송비 -->
      <input type="hidden" id="deliveryFee" value="${deliveryFee}">

      <!-- 적립포인트(표시용; 서버는 cartno로 재계산함) -->
      <input type="hidden" id="sumTotalPoint" value="${sumTotalPoint}">

      <!-- 사용포인트 -->
      <input type="hidden" id="usePoint" value="0">

      <input type="hidden" id="deliveryRequestFinal" value="">
    </aside>

  </div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="<%= ctxPath%>/js/order/buy.js"></script>
