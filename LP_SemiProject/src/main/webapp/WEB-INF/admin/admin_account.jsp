<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_account.css">
  
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>
  
  <main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" >회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp" class="active">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>회계 관리</h2>

      <div class="sales-summary">
        <div class="summary-box">
          <span class="label">오늘 매출</span>
          <strong class="amount">₩ 1,250,000</strong>
        </div>
        <div class="summary-box">
          <span class="label">이번 달 매출</span>
          <strong class="amount">₩ 18,430,000</strong>
        </div>
        <div class="summary-box">
          <span class="label">누적 매출</span>
          <strong class="amount">₩ 548,900,000</strong>
        </div>
      </div>

      <div class="chart-section">
        <div class="chart-header">
          <h3>매출 현황</h3>
          <div class="chart-controls">
            <select class="filter-select" id="searchType">
              <option value="month">월별</option>
              <option value="year">연도별</option>
            </select>

            <div class="date-range">
              <span class="box-month">
                <input type="month" id="startDate" value="2025-10" class="input-date">
                <span>~</span>
                <input type="month" id="endDate" value="2025-12" class="input-date">
              </span>

              <span class="box-year" style="display: none;">
                <select id="startYearSelect" class="input-date"></select>
                <span>~</span>
                <select id="endYearSelect" class="input-date"></select>
              </span>
            </div>

            <button class="btn-search" id="btnSearch">조회</button>
          </div>
        </div>

        <div class="chart-placeholder" id="chartBars"></div>
        <div class="chart-labels" id="chartLabels"></div>
      </div>
    </section>

  </div>
</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer2.jsp" />

<script src="<%= ctxPath%>/js/admin/admin_account.js"></script>