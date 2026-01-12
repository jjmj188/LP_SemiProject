<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>


<link rel="stylesheet" href="<%= ctxPath %>/css/my_info/tracking_modal.css">

<c:if test="${empty odto}">
  <div class="tracking-wrap">
    <div class="tracking-card">
      <p class="tracking-empty">배송 정보를 찾을 수 없습니다.</p>

      <div class="tracking-btns">
        <button type="button" class="tracking-btn tracking-btn-close" data-action="close-tracking">닫기</button>
      </div>
    </div>
  </div>
</c:if>

<c:if test="${not empty odto}">
  <div class="tracking-wrap">
    <div class="tracking-card">
      <div class="tracking-title-row">
        <h3 class="tracking-title">배송 정보</h3>
        <span class="tracking-badge">${odto.deliverystatus}</span>
      </div>

      <div class="tracking-rows">
        <div class="tracking-row">
          <div class="tracking-k">받는 사람</div>
          <div class="tracking-v">${sessionScope.loginuser.name}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">우편번호</div>
          <div class="tracking-v">${odto.postcode}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">주소</div>
          <div class="tracking-v">${odto.address}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">상세주소</div>
          <div class="tracking-v">${odto.detailaddress} ${odto.extraaddress}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">요청사항</div>
          <div class="tracking-v">${odto.deliveryrequest}</div>
        </div>
      </div>

      <h3 class="tracking-subtitle">송장 정보</h3>

      <div class="tracking-rows">
        <div class="tracking-row">
          <div class="tracking-k">택배사</div>
          <div class="tracking-v">${odto.deliveryCompany}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">송장번호</div>
          <div class="tracking-v">
            <c:choose>
              <c:when test="${not empty odto.invoiceNo}">
                ${odto.invoiceNo}
              </c:when>
              <c:otherwise>
                <span class="tracking-muted">(배송이 시작되면 송장번호를 확인할 수 있습니다)</span>
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">보내는이</div>
          <div class="tracking-v">${odto.senderName}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">발송일</div>
          <div class="tracking-v">${odto.shippedDate}</div>
        </div>

        <div class="tracking-row">
          <div class="tracking-k">완료일</div>
          <div class="tracking-v">${odto.deliveredDate}</div>
        </div>
      </div>

    </div>
  </div>
</c:if>
