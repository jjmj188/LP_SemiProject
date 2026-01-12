<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 문의내역</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_inquiry.css">

<script>const ctxPath = "<%= ctxPath %>";</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_inquiry.js"></script>

</head>
<body>

<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>

<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp">회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp" class="active">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>문의내역 관리 <span style="font-size:14px; color:#999; margin-left:10px;">(총 ${requestScope.totalCount}건)</span></h2>

      <table class="inquiry-table">
        <colgroup>
            <col width="8%">  <col width="12%"> <col width="*">   <col width="12%"> <col width="10%"> <col width="10%"> </colgroup>
        <thead>
          <tr>
            <th>번호</th>
            <th>작성일자</th>
            <th>문의내용</th>
            <th>작성자</th>
            <th>상태</th>
            <th>관리</th> 
          </tr>
        </thead>

        <tbody>
          <c:if test="${empty requestScope.inquiryList}">
              <tr><td colspan="6" style="padding:50px; color:#777;">등록된 문의가 없습니다.</td></tr>
          </c:if>

          <c:if test="${not empty requestScope.inquiryList}">
              <c:forEach var="ivo" items="${requestScope.inquiryList}" varStatus="status">
                  <tr>
                    <%-- [번호 출력] 오름차순 (시작값 + 인덱스) --%>
                    <td>${requestScope.startIter + status.index}</td>
                    
                    <td>${ivo.inquirydate}</td>
                    
                    <%-- 클릭 시 답변 모달 열기 --%>
                    <td class="content-cell" onclick="openModal('${ivo.inquiryno}', '${ivo.inquirycontent}', '${ivo.adminreply}')">
                         ${ivo.inquirycontent}
                    </td>
                    
                    <td>${ivo.fk_userid}</td>
                    
                    <td>
                        <c:if test="${ivo.inquirystatus == '대기'}">
                            <span class="status-wait">대기</span>
                        </c:if>
                        <c:if test="${ivo.inquirystatus == '답변완료'}">
                            <span class="status-done">답변완료</span>
                        </c:if>
                    </td>
                    
                    <td>
                      <button type="button" class="btn-reply" 
                              onclick="openModal('${ivo.inquiryno}', '${ivo.inquirycontent}', '${ivo.adminreply}')">
                          ${ivo.inquirystatus == '답변완료' ? '수정' : '답변'}
                      </button>
                    </td>
                  </tr>
              </c:forEach>
          </c:if>
        </tbody>
      </table>
      
      <div class="pagination">
        ${requestScope.pageBar}
      </div>
      
    </section>
  </div>
</main>

<div id="inquiryModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3>문의 답변 작성</h3>
      <button class="btn-close-modal" onclick="closeModal()">×</button>
    </div>
    
    <%-- 통합된 Controller로 POST 전송 --%>
    <form name="replyFrm" method="POST" action="<%= ctxPath%>/admin/admin_inquiry.lp">
        <div class="modal-body">
          <input type="hidden" id="modalInquiryNo" name="inquiryno" />
          
          <div class="inquiry-preview-box">
            <strong style="display:block; margin-bottom:5px;">문의 내용:</strong>
            <p id="modalInquiryText" class="preview-text">...</p>
          </div>
    
          <div class="form-group">
            <label style="display:block; margin-bottom:5px;"><strong>답변 내용</strong></label>
            <textarea id="modalReplyContent" name="adminreply" class="input-textarea" placeholder="고객님께 전송할 답변을 입력하세요."></textarea>
          </div>
        </div>
    
        <div class="modal-footer">
          <button type="button" class="btn-cancel-modal" onclick="closeModal()">취소</button>
          <button type="button" class="btn-submit-modal" onclick="goReply()">답변 등록</button>
        </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>