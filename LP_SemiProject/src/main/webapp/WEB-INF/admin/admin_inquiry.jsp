<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 문의내역</title>
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<style>
    /* 문의내역 테이블 스타일 */
    .inquiry-table { width: 100%; border-collapse: collapse; background: #fff; }
    .inquiry-table th, .inquiry-table td { border-bottom: 1px solid #eee; padding: 12px; text-align: center; }
    .inquiry-table th { background: #f9f9f9; font-weight: bold; color: #555; }
    .content-cell { text-align: left; padding-left: 20px; cursor: pointer; color: #333; }
    .content-cell:hover { text-decoration: underline; color: #000; }
    
    /* 상태 뱃지 */
    .status-wait { color: #d9534f; font-weight: bold; } /* 대기 - 빨강 */
    .status-done { color: #5cb85c; font-weight: bold; } /* 완료 - 초록 */
    
    /* 버튼 스타일 */
    .btn-reply { padding: 5px 10px; border: 1px solid #ccc; background: #fff; cursor: pointer; border-radius: 3px; }
    .btn-reply:hover { background: #eee; }

    /* 모달 스타일 */
    .modal-overlay { display: none; position: fixed; top: 0; left: 0; width: 100%; height: 100%; background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1000; }
    .modal-window { background: #fff; width: 500px; border-radius: 5px; box-shadow: 0 5px 15px rgba(0,0,0,0.3); overflow: hidden; }
    .modal-header { padding: 15px; background: #f1f1f1; border-bottom: 1px solid #ddd; display: flex; justify-content: space-between; align-items: center; }
    .modal-body { padding: 20px; }
    .inquiry-preview-box { background: #f9f9f9; padding: 15px; border-radius: 5px; margin-bottom: 15px; border: 1px solid #eee; }
    .preview-text { white-space: pre-wrap; margin-top: 5px; color: #555; }
    .input-textarea { width: 100%; height: 100px; padding: 10px; border: 1px solid #ddd; resize: none; box-sizing: border-box; }
    .modal-footer { padding: 15px; border-top: 1px solid #ddd; text-align: right; background: #f9f9f9; }
    .btn-submit-modal { background: #333; color: #fff; padding: 8px 20px; border: none; cursor: pointer; }
    .btn-cancel-modal { background: #fff; border: 1px solid #ccc; padding: 8px 15px; margin-right: 5px; cursor: pointer; }
</style>
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
      <h2>문의내역 관리</h2>

      <table class="inquiry-table">
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
              <tr><td colspan="6" style="padding:50px;">등록된 문의가 없습니다.</td></tr>
          </c:if>

          <c:if test="${not empty requestScope.inquiryList}">
              <c:forEach var="ivo" items="${requestScope.inquiryList}">
                  <tr>
                    <td>${ivo.inquiryno}</td>
                    <td>${ivo.inquirydate}</td>
                    
                    <%-- [Select] 클릭 시 모달 열기 --%>
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
                      <%-- [Update] 답변하기 버튼 --%>
                      <button type="button" class="btn-reply" 
                              onclick="openModal('${ivo.inquiryno}', '${ivo.inquirycontent}', '${ivo.adminreply}')">
                          ${ivo.inquirystatus == '완료' ? '답변수정' : '답변하기'}
                      </button>
                    </td>
                  </tr>
              </c:forEach>
          </c:if>
        </tbody>
      </table>
      
    </section>
  </div>
</main>

<div id="inquiryModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3>문의 답변 작성</h3>
      <button class="btn-close-modal" onclick="closeModal()">×</button>
    </div>
    
    <form name="replyFrm" method="POST" action="<%= ctxPath%>/admin/inquiryReplyEnd.lp">
        <div class="modal-body">
          <input type="hidden" id="modalInquiryNo" name="inquiryno" />
          
          <div class="inquiry-preview-box">
            <strong>문의 내용:</strong>
            <p id="modalInquiryText" class="preview-text">...</p>
          </div>
    
          <div class="form-group">
            <label><strong>답변 내용</strong></label>
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

<script>
    // 1. 모달 열기 (Select 기능 포함)
    function openModal(inquiryno, content, reply) {
        // 데이터 바인딩
        document.getElementById("modalInquiryNo").value = inquiryno;
        
        // 줄바꿈 처리 등을 위해 textContent 대신 innerText 사용 가능
        document.getElementById("modalInquiryText").innerText = content;
        
        // 기존 답변이 있으면 채워넣기 (수정 시 유용)
        // JSP에서 null값을 문자열 'null'이나 공백으로 넘길 때 처리
        if(reply && reply !== 'null') {
             document.getElementById("modalReplyContent").value = reply;
        } else {
             document.getElementById("modalReplyContent").value = "";
        }

        document.getElementById("inquiryModal").style.display = "flex";
    }

    // 2. 모달 닫기
    function closeModal() {
        document.getElementById("inquiryModal").style.display = "none";
    }

    // 3. 답변 등록 (Update 전송)
    function goReply() {
        const replyContent = document.getElementById("modalReplyContent").value;
        
        if(replyContent.trim() == "") {
            alert("답변 내용을 입력하세요.");
            return;
        }
        
        if(confirm("답변을 등록하시겠습니까?")) {
            // form submit
            document.replyFrm.submit();
        }
    }
</script>

</body>
</html>