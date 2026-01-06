<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
  request.setCharacterEncoding("UTF-8");
  String ctxPath = request.getContextPath();
  String ordNo = request.getParameter("ordNo");

  // TODO: 나중에 DB 조회로 교체
  // 예: TrackingDTO dto = orderDao.selectTracking(ordNo);
  String courier = "CJ대한통운";
  String invoiceNo = "1234-5678-9012";
  String sender = "LP Shop";
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>송장 정보</title>
  <meta name="viewport" content="width=device-width, initial-scale=1" />
  <style>
    body{margin:0;font-family:Arial,sans-serif;background:#f7f7f7;color:#222;}
    .wrap{padding:18px;}
    .card{background:#fff;border-radius:14px;padding:16px;box-shadow:0 6px 20px rgba(0,0,0,.08);}
    h2{margin:0 0 12px;font-size:18px;}
    .row{display:flex;gap:10px;padding:10px 0;border-top:1px solid #eee;}
    .row:first-of-type{border-top:none;}
    .k{width:90px;color:#666;flex:0 0 auto;}
    .v{font-weight:600;word-break:break-all;}
    .btns{display:flex;gap:10px;margin-top:14px;}
    button{border:0;border-radius:10px;padding:10px 12px;cursor:pointer;}
    .btn-close{background:#111;color:#fff;}
  </style>
</head>
<body>
  <div class="wrap">
    <div class="card">
      <h2>송장 정보</h2>

      <div class="row">
        <div class="k">주문번호</div>
        <div class="v"><%= (ordNo == null ? "-" : ordNo) %></div>
      </div>

      <div class="row">
        <div class="k">택배사</div>
        <div class="v"><%= courier %></div>
      </div>

      <div class="row">
        <div class="k">송장번호</div>
        <div class="v"><%= invoiceNo %></div>
      </div>

      <div class="row">
        <div class="k">보내는이</div>
        <div class="v"><%= sender %></div>
      </div>

      <div class="btns">
        <button type="button" class="btn-close" onclick="window.close()">닫기</button>
      </div>
    </div>
  </div>
</body>
</html>
