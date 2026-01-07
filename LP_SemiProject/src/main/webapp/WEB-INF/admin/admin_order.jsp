<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<%
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 주문/배송 관리</title>
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_order.css">
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
</head>
<body>
  
<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>
  
<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp">회원관리</a>
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
        <a href="#">배송준비중</a>
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
          <c:if test="${empty requestScope.orderList}">
             <tr>
                 <td colspan="9" style="text-align: center; padding: 20px;">주문 내역이 없습니다.</td>
             </tr>
          </c:if>

          <c:forEach var="odr" items="${requestScope.orderList}">
              <tr>
                <td>${odr.orderno}</td>
                <td>${odr.name}</td>
                <td>${odr.mobile}</td>
                <td>${odr.email}</td>
                
                <td class="text-left address-cell">
                  <span class="zipcode" id="zip_${odr.orderno}">[${odr.postcode}]</span>
                  
                  <button type="button" class="btn-addr-edit" 
                          onclick="openAddrModal('${odr.orderno}', '${odr.postcode}', '${odr.address}', '${odr.detailaddress}', '${odr.extraaddress}')">
                          수정
                  </button>
                  <br>
                  <span class="addr-text" id="addr1_${odr.orderno}">${odr.address}</span>
                  <span class="ref-addr" id="addr3_${odr.orderno}">${odr.extraaddress}</span>
                  <br>
                  <span class="detail-addr" id="addr2_${odr.orderno}">${odr.detailaddress}</span>
                </td>

                <td>${odr.productname}</td> <td>
                    <fmt:formatNumber value="${odr.totalprice}" pattern="#,###" />원
                </td>
                
                <td>
                  <select name="deliverystatus" id="status_${odr.orderno}">
                    <option value="배송준비중" ${odr.deliverystatus == '배송준비중' ? 'selected' : ''}>배송준비중</option>
                    <option value="배송중" ${odr.deliverystatus == '배송중' ? 'selected' : ''}>배송중</option>
                    <option value="배송완료"  ${odr.deliverystatus == '배송완료' ? 'selected' : ''}>배송완료</option>
                  </select>
                </td>
                <td>
                  <button class="save-btn" onclick="updateDelivery('${odr.orderno}')">저장</button>
                </td>
              </tr>
          </c:forEach>
        </tbody>
      </table>

      <div class="pagination">
        <a href="#" class="prev">&lsaquo;</a>
        <a href="#" class="active">1</a>
        <a href="#" class="next">&rsaquo;</a>
      </div>

    </section>
  </div>
</main>

<div id="addrModal" class="modal-overlay">
  <div class="modal-content">
      <h3>배송지 주소 수정</h3>
      
      <input type="hidden" id="modal_orderno">
      
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

<jsp:include page="/WEB-INF/footer2.jsp" />

<script src="<%= ctxPath%>/js/admin/admin_order.js"></script>

<script>
    // 모달 열기 (기존 값을 모달 인풋에 채워넣음)
    function openAddrModal(orderno, postcode, addr1, addr2, addr3) {
        document.getElementById('modal_orderno').value = orderno;
        document.getElementById('modal_zipcode').value = postcode;
        document.getElementById('modal_addr1').value = addr1;
        document.getElementById('modal_addr2').value = addr2;
        document.getElementById('modal_addr3').value = addr3;
        
        document.getElementById('addrModal').style.display = 'flex';
    }

    // 모달 닫기
    function closeModal() {
        document.getElementById('addrModal').style.display = 'none';
    }

    // (추후 구현) 주소 적용 및 배송상태 변경 Ajax 함수는 js 파일에서 작성 필요
    function applyAddress() {
        alert("주소 수정 기능은 Ajax 구현이 필요합니다.");
        closeModal();
    }
    
    function updateDelivery(orderno) {
        let status = document.getElementById('status_'+orderno).value;
        alert("주문번호: " + orderno + "\n변경할 상태: " + status + "\n(기능 구현 필요)");
    }
</script>

</body>
</html>