<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    body{ margin:0; font-family:Arial,sans-serif; background:#f7f7f7; color:#222; }
    .wrap{ padding:18px; }
    .card{ background:#fff; border-radius:14px; padding:16px; box-shadow:0 6px 20px rgba(0,0,0,.08); }
    h2{  font-size:18px; }
    .row{ display:flex; gap:10px; padding:10px 0; border-top:1px solid #eee; }
    .row:first-of-type{ border-top:none; }
    .k{ width:90px; color:#666; flex:0 0 auto; }
    .v{ font-weight:600; word-break:break-all; }
    .btns{ display:flex; gap:10px; margin-top:14px; }
    button{ border:0; border-radius:10px; padding:10px 12px; cursor:pointer; }
    .btn-close{ background:#111; color:#fff; }
    .badge{ display:inline-block; padding:4px 8px; border-radius:999px; background:#eee; font-size:12px; margin-left:8px; }
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">

      <c:if test="${empty odto}">
        <div style="padding:10px;">배송 정보를 찾을 수 없습니다.</div>
        <div class="btns">
          <button type="button" class="btn-close" onclick="window.close()">닫기</button>
        </div>
      </c:if>

      <c:if test="${not empty odto}">
        <h2>배송 정보 <span class="badge">${odto.deliverystatus}</span></h2>

        <div class="row">
          <div class="k">받는 사람:</div>
          <div class="v">${sessionScope.loginuser.name}</div>
        </div>

        <div class="row">
          <div class="k">우편번호:</div>
          <div class="v">${odto.postcode}</div>
        </div>

        <div class="row">
          <div class="k">주소</div>
          <div class="v">${odto.address}</div>
        </div>

        <div class="row">
          <div class="k">상세주소</div>
          <div class="v">${odto.detailaddress} ${odto.extraaddress}</div>
        </div>

        <div class="row">
          <div class="k">요청사항</div>
          <div class="v">${odto.deliveryrequest}</div>
        </div>

        <h2 style="margin-top:18px;">송장 정보</h2>
        
        <div class="row">
          <div class="k">택배사</div>
          <div class="v">${odto.deliveryCompany}</div>
        </div>

        <div class="row">
          <div class="k">송장번호</div>
          <div class="v">
            <c:choose>
              <c:when test="${not empty odto.invoiceNo}">
                ${odto.invoiceNo}
              </c:when>
              <c:otherwise>
                (배송이 시작되면 송장번호를 확인할 수 있습니다)
              </c:otherwise>
            </c:choose>
          </div>
        </div>

        <div class="row">
          <div class="k">보내는이</div>
          <div class="v">${odto.senderName}</div>
        </div>

        <div class="row">
          <div class="k">발송일</div>
          <div class="v">${odto.shippedDate}</div>
        </div>

        <div class="row">
          <div class="k">완료일</div>
          <div class="v">${odto.deliveredDate}</div>
        </div>

      </c:if>

    </div>
  </div>
</body>
</html>
