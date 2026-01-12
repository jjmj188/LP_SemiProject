<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 회계/매출 관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_account.css">

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="https://cdn.jsdelivr.net/npm/chart.js"></script> 

<script>const ctxPath = "<%= ctxPath %>";</script>
<script src="<%= ctxPath%>/js/admin/admin_account.js"></script>

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
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp" class="active">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>회계 / 매출 현황</h2>

      <div class="summary-container">
          <div class="summary-box">
              <span class="label">오늘 매출</span>
              <strong class="amount">
                  <fmt:formatNumber value="${requestScope.s_todaySales}" pattern="#,###" /> 원
              </strong>
          </div>
			<div class="summary-box">
			    <span class="label">이번 달 매출</span>
			    <strong class="amount">
			       ${requestScope.s_monthSales} 원
			    </strong>
			</div>
			
			<div class="summary-box highlight">
			    <span class="label">누적 매출 (Total)</span>
			    <strong class="amount">
			       ${requestScope.s_totalSales} 원
			    </strong>
			</div>
      </div>

      <div class="chart-wrapper">
          <div class="chart-header">
              <h3>매출 추이 분석</h3>
              
              <div class="chart-filter">
                  <select id="searchType">
                      <option value="month">월별 조회</option>
                      <option value="year">연도별 조회</option>
                  </select>
                  
                  <span id="monthRange">
                      <input type="month" id="startDate"> ~ <input type="month" id="endDate">
                  </span>
                  
                  <span id="yearRange" style="display:none;">
                      <select id="startYear"></select> ~ <select id="endYear"></select>
                  </span>
                  
                  <button type="button" onclick="updateChart()">조회</button>
              </div>
          </div>
          
          <div class="canvas-container">
              <canvas id="salesChart"></canvas>
          </div>
      </div>

    </section>
  </div>
</main>

<jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>