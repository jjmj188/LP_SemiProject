<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
  <link rel="stylesheet" href="../css/admin/admin_layout.css">
  <link rel="stylesheet" href="../css/admin/admin_order.css">
  <script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>
  
  <main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" >회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp" class="active">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>주문 · 배송 관리</h2>

      <div class="status-filter">
        <a href="#" class="active">전체</a>
        <a href="#">배송준비</a>
        <a href="#">배송중</a>
        <a href="#">배송완료</a>
      </div>

      <table class="order-table">
        <thead>
          <tr>
            <th>주문번호</th>
            <th>주문자</th>
            <th>전화번호</th> 
            <th>이메일</th>   
            <th>주소</th>     
            <th>주문상품</th>
            <th>결제금액</th>
            <th>상태</th>
            <th>저장</th>
          </tr>
        </thead>

        <tbody>
          <tr>
            <td>20250101</td>
            <td>홍길동</td>
            <td>010-1234-5678</td>
            <td>hong@example.com</td>
            
            <td class="text-left address-cell">
              <span class="zipcode">[06234]</span>
              <button type="button" class="btn-addr-edit">수정</button>
              <br>
              <span class="addr-text">서울특별시 강남구 테헤란로 123</span>
              <span class="ref-addr">(역삼동)</span>
              <br>
              <span class="detail-addr">A동 101호</span>
            </td>

            <td>LP - Beatles</td>
            <td>45,000원</td>
            <td>
              <select>
                <option selected>배송준비</option>
                <option>배송중</option>
                <option>배송완료</option>
              </select>
            </td>
            <td>
              <button class="save-btn">저장</button>
            </td>
          </tr>

          <tr>
            <td>20250102</td>
            <td>김소라</td>
            <td>010-9876-5432</td>
            <td>sora@test.com</td>
            
            <td class="text-left address-cell">
              <span class="zipcode">[13487]</span>
              <button type="button" class="btn-addr-edit">수정</button>
              <br>
              <span class="addr-text">경기도 성남시 분당구 판교로 202</span>
              <span class="ref-addr">(삼평동)</span>
              <br>
              <span class="detail-addr">B동 505호</span>
            </td>

            <td>LP - Queen</td>
            <td>39,000원</td>
            <td>
              <select>
                <option>배송준비</option>
                <option selected>배송중</option>
                <option>배송완료</option>
              </select>
            </td>
            <td>
              <button class="save-btn">저장</button>
            </td>
          </tr>
        </tbody>
      </table>

      <div class="pagination">
        <a href="#" class="prev">&lsaquo;</a>
        <a href="#" class="active">1</a>
        <a href="#">2</a>
        <a href="#">3</a>
        <a href="#">4</a>
        <a href="#">5</a>
        <a href="#" class="next">&rsaquo;</a>
      </div>

    </section>
  </div>
</main>

<div id="addrModal" class="modal-overlay">
  <div class="modal-content">
      <h3>배송지 주소 수정</h3>
      <div class="modal-body">
          <div class="input-group">
              <input type="text" id="modal_zipcode" placeholder="우편번호" readonly>
              <button type="button" onclick="execDaumPostcode()">주소 찾기</button>
          </div>
          <input type="text" id="modal_addr1" placeholder="도로명 주소" readonly>
          <input type="text" id="modal_addr3" placeholder="참고항목" readonly>
          <input type="text" id="modal_addr2" placeholder="상세주소 입력">
      </div>
      <div class="modal-footer">
          <button type="button" class="btn-cancel" onclick="closeModal()">취소</button>
          <button type="button" class="btn-save" onclick="applyAddress()">적용</button>
      </div>
  </div>
</div>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer2.jsp" />
<script src="<%= ctxPath%>/js/admin/admin_order.js">