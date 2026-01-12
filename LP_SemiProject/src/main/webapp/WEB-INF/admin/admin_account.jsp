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

                <%-- 1. 상단 매출 요약 정보 (Controller에서 넘겨준 값 출력) --%>
                <div class="sales-summary">
                    <div class="summary-box">
                        <span class="label">오늘 매출</span>
                        <strong class="amount">
                            <fmt:formatNumber value="${requestScope.s_todaySales}" pattern="#,###" /> 원
                        </strong>
                    </div>
                    <div class="summary-box">
                        <span class="label">이번 달 매출</span>
                        <strong class="amount">
                            <fmt:formatNumber value="${requestScope.s_monthSales}" pattern="#,###" /> 원
                        </strong>
                    </div>
                    <div class="summary-box">
                        <span class="label">누적 매출 (Total)</span>
                        <strong class="amount">
                            <fmt:formatNumber value="${requestScope.s_totalSales}" pattern="#,###" /> 원
                        </strong>
                    </div>
                </div>

                <%-- 2. 매출 상세 차트 조회 영역 --%>
                <div class="chart-section">
                    <div class="chart-header">
                        <h3>매출 상세 조회</h3>
                        
                        <div class="chart-controls">
                            <label for="searchType" style="margin-right:5px; font-weight:500;">기준:</label>
                            <select class="filter-select" id="searchType">
                                <option value="month">월별 조회</option>
                                <option value="year">연도별 조회</option>
                            </select>

                            <div class="date-range" style="margin-left: 10px;">
                                <%-- [A] 월별 조회 UI --%>
                                <span class="box-month">
                                    <input type="month" id="startDate" class="input-date">
                                    <span style="margin:0 5px;">~</span>
                                    <input type="month" id="endDate" class="input-date">
                                </span>

                                <%-- [B] 연도별 조회 UI (JS로 제어하여 표시) --%>
                                <span class="box-year" style="display: none;">
                                    <select id="startYearSelect" class="input-date"></select>
                                    <span style="margin:0 5px;">~</span>
                                    <select id="endYearSelect" class="input-date"></select>
                                </span>
                            </div>

                            <button type="button" class="btn-search" id="btnSearch" style="margin-left: 10px;">조회하기</button>
                        </div>
                    </div>

                    <%-- 차트 막대가 그려질 영역 (JS가 내용을 채움) --%>
                    <div class="chart-placeholder" id="chartBars">
                        <div style="margin: auto; color: #aaa; font-size: 14px;">
                            상단 조회 버튼을 눌러 데이터를 확인하세요.
                        </div>
                    </div>
                    
                    <%-- 차트 하단 라벨 (날짜/연도) --%>
                    <div class="chart-labels" id="chartLabels"></div>
                </div>
            </section>

        </div>
    </main>

    <jsp:include page="/WEB-INF/footer2.jsp" />

    <script src="<%= ctxPath%>/js/admin/admin_account.js"></script>

</body>
</html>