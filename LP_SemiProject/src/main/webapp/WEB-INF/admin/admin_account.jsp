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
<title>관리자 페이지 - 회계 관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_account.css">

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
    /* 차트 CSS가 아직 없을 경우를 대비한 임시 스타일 */
    .chart-placeholder {
        display: flex;
        align-items: flex-end; /* 아래 정렬 */
        justify-content: space-around;
        height: 300px;
        border-bottom: 2px solid #ddd;
        padding: 0 20px;
        margin-top: 20px;
    }
    .bar {
        width: 40px;
        background-color: #4CAF50; /* 막대 색상 */
        transition: height 0.5s ease;
        border-radius: 5px 5px 0 0;
        cursor: pointer;
        position: relative;
    }
    .bar:hover {
        background-color: #45a049;
    }
    .chart-labels {
        display: flex;
        justify-content: space-around;
        margin-top: 10px;
        padding: 0 20px;
        color: #666;
        font-size: 14px;
    }
    .chart-controls {
        display: flex;
        gap: 10px;
        align-items: center;
        margin-bottom: 20px;
        background: #f9f9f9;
        padding: 15px;
        border-radius: 8px;
    }
    .summary-box {
        background: white;
        padding: 20px;
        border-radius: 8px;
        box-shadow: 0 2px 5px rgba(0,0,0,0.1);
        text-align: center;
        flex: 1;
    }
    .sales-summary {
        display: flex;
        gap: 20px;
        margin-bottom: 30px;
    }
    .amount {
        display: block;
        font-size: 1.5em;
        color: #333;
        margin-top: 10px;
    }
</style>

</head>
<body>

    <jsp:include page="/WEB-INF/header2.jsp" />
  
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
                <h2>회계 관리</h2>

                <div class="sales-summary">
                    <div class="summary-box">
                        <span class="label">오늘 매출</span>
                        <strong class="amount">₩ ${requestScope.s_todaySales}</strong>
                    </div>
                    <div class="summary-box">
                        <span class="label">이번 달 매출</span>
                        <strong class="amount">₩ ${requestScope.s_monthSales}</strong>
                    </div>
                    <div class="summary-box">
                        <span class="label">누적 매출 (Total)</span>
                        <strong class="amount">₩ ${requestScope.s_totalSales}</strong>
                    </div>
                </div>

                <div class="chart-section">
                    <div class="chart-header">
                        <h3>매출 상세 조회</h3>
                        
                        <div class="chart-controls">
                            <label>조회 기준: </label>
                            <select class="filter-select" id="searchType">
                                <option value="month">월별 조회</option>
                                <option value="year">연도별 조회</option>
                            </select>

                            <div class="date-range">
                                <span class="box-month">
                                    <input type="month" id="startDate" value="2025-01" class="input-date">
                                    <span>~</span>
                                    <input type="month" id="endDate" value="2025-12" class="input-date">
                                </span>

                                <span class="box-year" style="display: none;">
                                    <select id="startYearSelect" class="input-date"></select>
                                    <span>~</span>
                                    <select id="endYearSelect" class="input-date"></select>
                                </span>
                            </div>

                            <button type="button" class="btn-search" id="btnSearch">조회하기</button>
                        </div>
                    </div>

                    <div class="chart-placeholder" id="chartBars">
                        <div style="margin: auto; color: #999;">데이터를 조회해주세요.</div>
                    </div>
                    
                    <div class="chart-labels" id="chartLabels"></div>
                </div>
            </section>

        </div>
    </main>

    <jsp:include page="/WEB-INF/footer2.jsp" />

    <script src="<%= ctxPath%>/js/admin/admin_account.js"></script>

</body>
</html>