<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_inquiry.css">

<!-- HEADER -->
<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>

<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" >회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp" class="active">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>문의내역 관리</h2>

      <table class="inquiry-table">
        <thead>
          <tr>
            <th>작성일자</th>
            <th>문의내용</th>
            <th>작성자</th>
            <th>처리상태</th>
            <th>관리</th> </tr>
        </thead>

        <tbody>
          <tr>
            <td>2025-01-05</td>
            <td class="content">배송이 언제 시작되나요?</td>
            <td>김소라</td>
            <td>
              <select class="status-select">
                <option value="wait" selected>대기</option>
                <option value="done">답변완료</option>
              </select>
            </td>
            <td>
              <button class="btn-reply">답변하기</button>
            </td>
          </tr>

          <tr>
            <td>2025-01-04</td>
            <td class="content">환불 요청드립니다.</td>
            <td>홍길동</td>
            <td>
              <select class="status-select">
                <option value="wait">대기</option>
                <option value="done" selected>답변완료</option>
              </select>
            </td>
            <td>
              <button class="btn-reply">답변수정</button>
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

<div id="inquiryModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3>문의 답변 작성</h3>
      <button class="btn-close-modal">×</button>
    </div>
    
    <div class="modal-body">
      <div class="inquiry-preview-box">
        <strong>문의 내용:</strong>
        <p id="modalInquiryText" class="preview-text">...</p>
      </div>

      <div class="form-group">
        <label>답변 내용</label>
        <textarea class="input-textarea" placeholder="고객님께 전송할 답변을 입력하세요."></textarea>
      </div>
    </div>

    <div class="modal-footer">
      <button class="btn-cancel-modal">취소</button>
      <button class="btn-submit-modal">답변 등록</button>
    </div>
  </div>
</div>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer2.jsp" />
<script src="<%= ctxPath%>/js/admin/admin_inquiry.js"></script>