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
<script>
    const ctxPath = "<%= ctxPath %>";

    // 배송 시작 버튼 클릭 (AJAX)
    function goDeliveryStart(orderno) {
        const receiver = $("#receiver_" + orderno).val();
        const company = $("#company_" + orderno).val();
        const invoice = $("#invoice_" + orderno).val();

        if(!receiver) { alert("받는 분 성함을 입력하세요."); return; }
        if(!company)  { alert("택배사를 선택하세요."); return; }
        if(!invoice)  { alert("송장번호를 입력하세요."); return; }

        if(!confirm("주문번호 " + orderno + "번의 배송을 시작하시겠습니까?")) return;

        $.ajax({
            url: ctxPath + "/admin/admin_order.lp",
            type: "POST",
            data: {
                "mode": "updateDelivery",
                "orderno": orderno,
                "receiverName": receiver,
                "delivery_company": company,
                "invoice_no": invoice
            },
            dataType: "json",
            success: function(json) {
                if(json.result == 1) {
                    alert("배송 처리가 완료되었습니다.");
                    location.reload();
                } else {
                    alert("배송 처리 실패. 다시 시도해주세요.");
                }
            },
            error: function(request, status, error) {
                alert("에러 발생: " + error);
            }
        });
    }

    // [추가] 배송 완료 버튼 클릭 (AJAX)
    function goDeliveryEnd(orderno) {
        if(!confirm("주문번호 " + orderno + "번을 [배송완료] 처리하시겠습니까?")) return;
        
        $.ajax({
            url: ctxPath + "/admin/admin_order.lp",
            type: "POST",
            data: {
                "mode": "updateDeliveryEnd",
                "orderno": orderno
            },
            dataType: "json",
            success: function(json) {
                if(json.result == 1) {
                    alert("배송완료 처리되었습니다.");
                    location.reload();
                } else {
                    alert("처리 실패. 다시 시도해주세요.");
                }
            }
        });
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
        <colgroup>
            <col width="8%"> <col width="10%"> <col width="*"> <col width="12%"> <col width="10%"> <col width="10%"> <col width="22%">
        </colgroup>
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
                        <c:choose>
                            <c:when test="${map.deliverystatus eq '배송준비중'}">
                                <input type="text" id="receiver_${map.orderno}" class="input-name" value="${map.name}">
                            </c:when>
                            <c:otherwise><strong>${map.name}</strong></c:otherwise>
                        </c:choose>
                    </td>
                    <td class="addr-info">
                        [${map.postcode}] ${map.address} ${map.detailaddress} ${map.extraaddress}
                        <div class="contact-info">Phone: ${map.mobile} / Email: ${map.email}</div>
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
                                <select id="company_${map.orderno}" class="select-courier">
                                    <option value="">택배사 선택</option>
                                    <option value="CJ대한통운">CJ대한통운</option>
                                    <option value="우체국택배">우체국택배</option>
                                    <option value="한진택배">한진택배</option>
                                </select>
                                <div style="display:flex; justify-content:center; align-items:center; gap:2px;">
                                    <input type="text" id="invoice_${map.orderno}" class="input-invoice" placeholder="송장번호 입력">
                                    <button type="button" class="btn-ship" onclick="goDeliveryStart('${map.orderno}')">발송</button>
                                </div>
                            </c:when>
                            <c:when test="${map.deliverystatus eq '배송중'}">
                                <button type="button" class="btn-ship" style="background-color:#28a745; margin-bottom:5px;" 
                                        onclick="goDeliveryEnd('${map.orderno}')">배송완료 처리</button>
                                <div style="font-size:11px; color:#777;">(운송장 등록됨)</div>
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

<jsp:include page="/WEB-INF/footer2.jsp" />
</body>
</html>