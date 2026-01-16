<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %> 

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 주문/배송 관리</title>

<%-- CSS --%>
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_order.css">

<%-- JS --%>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_order.js"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>

<script>
    const ctxPath = "<%= ctxPath %>";
    
    // JS 함수: updateMaxLength (기존 코드 유지)
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
        <colgroup>
            <col width="8%">  <%-- 주문번호 --%>
            <col width="8%">  <%-- 받는 분 --%>
            <col width="25%"> <%-- 배송지/연락처 --%>
            <col width="30%"> <%-- 주문상품 --%>
            <col width="10%"> <%-- 결제금액 --%>
            <col width="8%">  <%-- 상태 --%>
            <col width="11%"> <%-- 배송 정보 입력 --%>
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
                        <strong>${map.name}</strong>
                        <input type="hidden" id="receiver_${map.orderno}" value="${map.name}">
                    </td>
                    
                    <td class="addr-info" style="text-align: left;">
                        [${map.postcode}] ${map.address}<br>
                        ${map.detailaddress} ${map.extraaddress}<br>
                        <%-- [수정] 복호화된 연락처 표시 --%>
                        <span style="font-size:12px; color:#888;">${map.mobile}</span>
                        <div style="margin-top:5px;">
                            <button type="button" class="btn-addr-edit" 
                                    onclick="openAddrModal('${map.orderno}', '${map.postcode}', '${map.address}', '${map.detailaddress}', '${map.extraaddress}')">수정</button>
                        </div>
                    </td>
                    
                    <%-- [수정] 주문상품 리스트 및 이미지 처리 --%>
                    <td style="text-align: left; padding: 10px;">
                        <c:set var="items" value="${fn:split(map.product_info, '~~')}" />
                        
                        <div style="display:flex; flex-direction:column; gap:8px;">
                            <c:forEach var="itemStr" items="${items}">
                                <c:set var="info" value="${fn:split(itemStr, '^^')}" />
                                <%-- info[0]:이미지, info[1]:이름, info[2]:수량, info[3]:가격 --%>
                                
                                <div style="display:flex; align-items:center; border-bottom:1px dashed #eee; padding-bottom:5px;">
                                    
                                    <%-- [이미지 경로 자동 보정 로직] --%>
                                    <c:set var="imgVal" value="${fn:trim(info[0])}" />
                                    <c:choose>
                                        <%-- 1. DB 값이 비어있는 경우: 기본 이미지 --%>
                                        <c:when test="${empty imgVal}">
                                             <div style="width:40px; height:40px; background:#eee; border-radius:4px; margin-right:10px; border:1px solid #ddd; display:flex; align-items:center; justify-content:center; font-size:10px; color:#999;">No Img</div>
                                        </c:when>
                                        <%-- 2. /images 로 시작하는 경우 (절대경로) --%>
                                        <c:when test="${fn:startsWith(imgVal, '/images')}">
                                            <img src="${pageContext.request.contextPath}${imgVal}" 
                                                 width="40" height="40" 
                                                 style="object-fit:cover; border-radius:4px; margin-right:10px; border:1px solid #ddd; background:#f8f8f8;">
                                        </c:when>
                                        <%-- 3. 파일명만 있는 경우 (상대경로) -> 앞에 경로 붙여줌 --%>
                                        <c:otherwise>
                                            <img src="${pageContext.request.contextPath}/images/productimg/${imgVal}" 
                                                 width="40" height="40" 
                                                 style="object-fit:cover; border-radius:4px; margin-right:10px; border:1px solid #ddd; background:#f8f8f8;">
                                        </c:otherwise>
                                    </c:choose>
                                    
                                    <div style="flex:1;">
                                        <div style="font-size:13px; font-weight:bold; color:#333; overflow:hidden; text-overflow:ellipsis; white-space:nowrap; max-width:280px;">
                                            ${info[1]}
                                        </div>
                                        <div style="font-size:12px; color:#666;">
                                            <fmt:formatNumber value="${info[3]}" pattern="#,###" />원 
                                            <span style="color:#d9534f; font-weight:bold; margin-left:5px;">(x${info[2]})</span>
                                        </div>
                                    </div>
                                </div>
                            </c:forEach>
                        </div>
                    </td>
                    
                    <%-- [결제금액 및 총 수량] --%>
                    <td>
                        <div style="font-weight:bold; color:#333;">
                            <fmt:formatNumber value="${map.totalprice}" pattern="#,###" />원
                        </div>
                        <div style="font-size:12px; color:#d9534f; font-weight:bold; margin-top:3px;">
                            (총 ${map.total_qty}개)
                        </div>
                    </td>
                    
                    <%-- 상태 --%>
                    <td>
                        <c:if test="${map.deliverystatus eq '배송준비중'}"><span class="badge st-ready">준비중</span></c:if>
                        <c:if test="${map.deliverystatus eq '배송중'}"><span class="badge st-ship">배송중</span></c:if>
                        <c:if test="${map.deliverystatus eq '배송완료'}"><span class="badge st-done">완료</span></c:if>
                    </td>
                    
                    <%-- 배송 정보 입력 --%>
                    <td>
                        <c:choose>
                            <c:when test="${map.deliverystatus eq '배송준비중'}">
                                <select id="company_${map.orderno}" class="select-courier" 
                                        onchange="updateMaxLength('${map.orderno}')"
                                        onkeydown="return false;" onfocus="this.blur()" tabindex="-1" style="cursor: pointer;">
                                    <option value="">택배사 선택</option>
                                    <option value="CJ대한통운">CJ대한통운</option>
                                    <option value="한진택배">한진택배</option>
                                    <option value="우체국택배">우체국택배</option>
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

<%-- 주소 수정 모달 --%>
<div id="addrModal" class="modal-overlay" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:999; justify-content:center; align-items:center;">
    <div class="modal-content" style="background:white; padding:25px; width:400px; position:absolute; top:50%; left:50%; transform:translate(-50%, -50%); border-radius:8px;">
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