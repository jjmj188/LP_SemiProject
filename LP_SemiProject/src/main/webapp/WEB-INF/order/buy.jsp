<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

  <%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
	%>
  
  <!-- BUY 전용 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/order/buy.css">
  <link rel="stylesheet" href="<%= ctxPath%>/css/order/cart.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
  <!-- MAIN -->
<main class="buy-wrapper">
  <div class="buy-container">

    <!-- ================= LEFT ================= -->
    <section class="buy-left">

      <div class="buy-card">
        <h3>주문자 / 배송 정보</h3>

        <div class="form-group">
          <label>주문자 이름</label>
          <input type="text" placeholder="이름 입력">
        </div>

        <div class="form-group">
          <label>연락처</label>
          <input type="text" placeholder="010-0000-0000">
        </div>

        <div class="form-group">
          <label>이메일</label>
          <input type="email" placeholder="email@example.com">
        </div>

        <hr>

        <!-- 포인트 -->
        <div class="form-group">
          <label class="title">포인트 사용</label>
          <input type="text" class="point-input" value="1,200 P" readonly>

          <div class="point-check-row">
            <label>
              <input type="checkbox">
              포인트 전부 사용하기
            </label>
          </div>
        </div>

        <hr>

        <!-- 주소 -->
        <div class="form-group">
          <label>배송 주소</label>
          <div class="address-row">
            <input type="text" placeholder="우편번호" readonly>
            <button type="button">우편번호 찾기</button>
          </div>
        </div>

        <div class="form-group">
          <input type="text" placeholder="주소">
        </div>

        <div class="form-group">
          <input type="text" placeholder="상세주소">
        </div>

        <div class="form-group">
          <input type="text" placeholder="참고항목">
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
    <span>₩82,000</span>
  </div>

  <div class="summary-row">
    <span>할인금액</span>
    <span>- ₩5,000</span>
  </div>

  <div class="summary-row">
    <span>배송비</span>
    <span>₩3,000</span>
  </div>

  <hr>

  <div class="summary-row total">
    <span>총 결제금액</span>
    <span>₩80,000</span>
  </div>

  <div class="summary-row point">
    <span>적립 포인트</span>
    <span>800P</span>
  </div>

  <div class="action-buttons">
    <button class="cart" onclick="location.href='../main_page.html'">
      더 담으러가기
    </button>
    <button class="buy" onclick="location.href='buy.html'">
      구매하기
    </button>
  </div>

</section>


</aside>

  </div>
</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="<%= ctxPath%>/js/order/buy.js"></script>