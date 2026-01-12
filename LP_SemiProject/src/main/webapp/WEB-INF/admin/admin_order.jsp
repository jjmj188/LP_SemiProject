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

<script>const ctxPath = "<%= ctxPath %>";</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="//t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_order.js"></script>

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
        <button type="button" class="filter-btn active" onclick="filterOrder('all', this)">전체</button>
        <button type="button" class="filter-btn" onclick="filterOrder('ready', this)">배송준비중</button>
        <button type="button" class="filter-btn" onclick="filterOrder('shipping', this)">배송중</button>
        <button type="button" class="filter-btn" onclick="filterOrder('complete', this)">배송완료</button>
      </div>

      <table class="order-table">
        <colgroup>
            <col width="8%"> <col width="10%"> <col width="30%"> <col width="15%"> <col width="10%"> <col width="8%"> <col width="19%"> 
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

        <tbody id="orderTableBody">
          <c:if test="${empty requestScope.orderList}">
             <tr>
                 <td colspan="7" style="text-align: center; padding: 40px;">주문 내역이 없습니다.</td>
             </tr>
          </c:if>

          <c:forEach var="odr" items="${requestScope.orderList}">
              
              <%-- 상태값에 따른 필터링 키 설정 --%>
              <c:set var="statusKey" value="ready" />
              <c:if test="${odr.deliverystatus == '배송중'}">
                  <c:set var="statusKey" value="shipping" />
              </c:if>
              <c:if test="${odr.deliverystatus == '배송완료'}">
                  <c:set var="statusKey" value="complete" />
              </c:if>

              <tr data-status="${statusKey}">
                <td>${odr.orderno}</td>
                
                <td>
                  <c:choose>
                        <c:when test="${odr.deliverystatus == '배송준비중'}">
                             <input type="text" id="name_${odr.orderno}" class="input-name" value="${odr.name}">
                        </c:when>
                        <c:otherwise>
                             <b>${odr.name}</b>
                        </c:otherwise>
                    </c:choose>
                </td>
                
                <td class="addr-info">
                  <div style="margin-bottom: 2px;">
                      <span id="zip_${odr.orderno}" style="font-weight:bold;">[${odr.postcode}]</span>
                      <c:if test="${odr.deliverystatus == '배송준비중'}">
                          <button type="button" class="btn-addr-edit" 
                                  onclick="openAddrModal('${odr.orderno}', '${odr.postcode}', '${odr.address}', '${odr.detailaddress}', '${odr.extraaddress}')">
                                  주소수정
                          </button>
                      </c:if>
                  </div>
                  <span id="addr1_${odr.orderno}">${odr.address}</span> 
                  <span id="addr2_${odr.orderno}">${odr.detailaddress}</span>
                  <span id="addr3_${odr.orderno}">${odr.extraaddress}</span>
                  <div class="contact-info">
                      Phone: ${odr.mobile} / Email: ${odr.email}
                  </div>
                </td>

                <td>${odr.productname}</td> 
                
                <td>
                    <fmt:formatNumber value="${odr.totalprice}" pattern="#,###" />원
                </td>
                 
                <td>
                    <c:choose>
                        <c:when test="${odr.deliverystatus == '배송준비중'}"><span class="badge st-ready">준비중</span></c:when>
                        <c:when test="${odr.deliverystatus == '배송중'}"><span class="badge st-ship">배송중</span></c:when>
                        <c:when test="${odr.deliverystatus == '배송완료'}"><span class="badge st-done">완료</span></c:when>
                    </c:choose>
                </td>
                
                <td>
                  <c:choose>
                    <%-- [Case A] 배송준비중: 입력 폼 노출 --%>
                    <c:when test="${odr.deliverystatus == '배송준비중'}">
                        <div style="display:flex; flex-direction:column; align-items:center; gap:2px;">
                            <select id="company_${odr.orderno}" class="select-courier">
                                <option value="CJ대한통운">CJ대한통운</option>
                                <option value="우체국택배">우체국택배</option>
                                <option value="한진택배">한진택배</option>
                                <option value="로젠택배">로젠택배</option>
                            </select>
                            
                            <div style="display:flex;">
                                <input type="text" id="invoice_${odr.orderno}" class="input-invoice" placeholder="송장번호 숫자만">
                                <button type="button" class="btn-ship" onclick="goShipping('${odr.orderno}')">배송<br>시작</button>
                            </div>
                        </div>
                    </c:when>
                     
                    <%-- [Case B] 배송중/완료: 정보 텍스트 노출 --%>
                    <c:otherwise>
                        <div style="font-size:12px; color:#555; text-align:left; padding-left:15px;">
                            📦 <b>${odr.delivery_company}</b><br>
                            NO. ${odr.invoice_no}
                        </div>
                    </c:otherwise>
                  </c:choose>
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
              <input type="text" id="modal_zipcode" placeholder="우편번호" readonly style="width: 70%;">
              <button type="button" onclick="execDaumPostcode()" style="padding: 8px;">주소 찾기</button>
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

</body>
</html>