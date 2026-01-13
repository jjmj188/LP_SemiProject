<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 주문/배송 관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_order.css">

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_order.js"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    const ctxPath = "<%= ctxPath %>";

    // 택배사 선택 시 입력창의 maxlength를 동적으로 변경하는 함수
    function updateMaxLength(orderno) {
        const company = $("#company_" + orderno).val();
        const $invoiceInput = $("#invoice_" + orderno);
        
        $invoiceInput.val(""); 

        if (company === "CJ대한통운" || company === "한진택배") {
            $invoiceInput.attr("maxlength", 12);
        } else if (company === "우체국택배") {
            $invoiceInput.attr("maxlength", 13);
        } else {
            $invoiceInput.removeAttr("maxlength");
        }
    }
</script>
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

      <div class="filter-container">
          <button type="button" class="filter-btn ${empty requestScope.status ? 'active' : ''}" 
                  onclick="location.href='<%= ctxPath %>/admin/admin_order.lp'">전체</button>
          <button type="button" class="filter-btn ${requestScope.status == '배송준비중' ? 'active' : ''}" 
                  onclick="location.href='<%= ctxPath %>/admin/admin_order.lp?status=배송준비중'">배송준비중</button>
          <button type="button" class="filter-btn ${requestScope.status == '배송중' ? 'active' : ''}" 
                  onclick="location.href='<%= ctxPath %>/admin/admin_order.lp?status=배송중'">배송중</button>
          <button type="button" class="filter-btn ${requestScope.status == '배송완료' ? 'active' : ''}" 
                  onclick="location.href='<%= ctxPath %>/admin/admin_order.lp?status=배송완료'">배송완료</button>
      </div>

      <table class="order-table">
        <thead>
            <tr>
                <th>주문번호</th>
                <th>받는 분</th>
                <th>배송지 / 연락처</th>
                <th>주문상품</th>
                <th>결제금액</th>
                <th>상태</th>
                <th>배송 정보 입력</th>
            </tr>
        </thead>
        <tbody>
            <c:if test="${empty requestScope.orderList}">
                <tr><td colspan="7" style="padding:50px; color:#777;">주문 내역이 없습니다.</td></tr>
            </c:if>

            <c:forEach var="map" items="${requestScope.orderList}">
                <tr>
                    <td>${map.orderno}</td>
                    <td>
                        <%-- [수정] 받는 분 이름을 모든 상태에서 텍스트로 출력 --%>
                        <strong>${map.name}</strong>
                        <%-- js에서 참조하기 위한 hidden 필드 --%>
                        <input type="hidden" id="receiver_${map.orderno}" value="${map.name}">
                    </td>
                    <td class="addr-info">
                        [${map.postcode}] ${map.address} ${map.detailaddress} ${map.extraaddress}
                        <button type="button" class="btn-addr-edit" 
                                onclick="openAddrModal('${map.orderno}', '${map.postcode}', '${map.address}', '${map.detailaddress}', '${map.extraaddress}')">수정</button>
                    </td>
                    <td>${map.productname}</td>
                    <td><fmt:formatNumber value="${map.totalprice}" pattern="#,###" />원</td>
                    <td>
                        <c:if test="${map.deliverystatus eq '배송준비중'}"><span class="badge st-ready">준비중</span></c:if>
                        <c:if test="${map.deliverystatus eq '배송중'}"><span class="badge st-ship">배송중</span></c:if>
                        <c:if test="${map.deliverystatus eq '배송완료'}"><span class="badge st-done">완료</span></c:if>
                    </td>
                    <td>
                        <c:choose>
                            <c:when test="${map.deliverystatus eq '배송준비중'}">
                                <%-- [수정] 키보드 입력 차단을 위한 onkeydown, onfocus, tabindex 추가 --%>
                                <select id="company_${map.orderno}" class="select-courier" 
                                        onchange="updateMaxLength('${map.orderno}')"
                                        onkeydown="return false;"
                                        onfocus="this.blur()"
                                        tabindex="-1"
                                        style="cursor: pointer;">
                                    <option value="">택배사 선택</option>
                                    <option value="CJ대한통운">CJ대한통운 (12자리)</option>
                                    <option value="한진택배">한진택배 (12자리)</option>
                                    <option value="우체국택배">우체국택배 (13자리)</option>
                                </select>
                                <div style="display:flex; justify-content:center; align-items:center; gap:2px; margin-top:5px;">
                                    <input type="text" id="invoice_${map.orderno}" class="input-invoice" placeholder="송장번호" 
                                           oninput="this.value = this.value.replace(/[^0-9]/g, '');">
                                    <button type="button" class="btn-ship" onclick="goDeliveryStart('${map.orderno}')">발송</button>
                                </div>
                            </c:when>
                            <c:when test="${map.deliverystatus eq '배송중'}">
                                <button type="button" class="btn-ship" style="background-color:#28a745;" 
                                        onclick="goDeliveryEnd('${map.orderno}')">배송완료 처리</button>
                            </c:when>
                            <c:otherwise>
                                <span style="font-size:12px; color:#888;">배송 완료됨</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
      </table>
    </section>
  </div>
</main>

<div id="addrModal" class="modal-overlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:999; justify-content:center; align-items:center;">
    <div class="modal-content" style="background:white; padding:25px; width:400px;">
        <h3>배송지 정보 수정</h3>
        <div class="modal-body">
            <input type="hidden" id="modal_orderno">
            <div style="display:flex; gap:8px; margin-bottom:10px;">
                <input type="text" id="modal_zipcode" placeholder="우편번호" readonly style="flex:1; padding:8px;">
                <button type="button" onclick="execDaumPostcode()" style="padding:0 15px; background:#222; color:#fff; border:none; cursor:pointer;">주소찾기</button>
            </div>
            <input type="text" id="modal_addr1" placeholder="주소" readonly style="width:100%; padding:8px; margin-bottom:10px; border:1px solid #ddd;">
            <input type="text" id="modal_addr2" placeholder="상세주소" style="width:100%; padding:8px; margin-bottom:10px; border:1px solid #ddd;">
            <input type="text" id="modal_addr3" placeholder="참고항목" readonly style="width:100%; padding:8px; margin-bottom:10px; border:1px solid #ddd;">
        </div>
        <div style="text-align:right;">
            <button type="button" onclick="closeModal()" style="padding:8px 16px; margin-right:5px; border:1px solid #ccc; background:#fff; cursor:pointer;">취소</button>
            <button type="button" onclick="applyAddress()" style="padding:8px 16px; background:#333; color:white; border:none; cursor:pointer;">저장</button>
        </div>
    </div>
</div>

<jsp:include page="/WEB-INF/footer2.jsp" />
</body>
</html>