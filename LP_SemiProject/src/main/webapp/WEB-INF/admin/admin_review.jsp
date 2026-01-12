<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 - 리뷰 관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_review.css">

<script>const ctxPath = "<%= ctxPath %>";</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_review.js"></script>

</head>
<body>

<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>

<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp">회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp" class="active">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>리뷰 관리</h2>

      <div class="review-control">
        <div style="display:flex; align-items:center;">
             <input type="checkbox" id="checkAll" style="margin-right:8px;">
             <label for="checkAll" style="font-size:14px; cursor:pointer;">전체 선택</label>
        </div>
        <button type="button" class="btn-delete" onclick="goDelete()">선택 삭제</button>
      </div>

      <table class="review-table">
        <colgroup>
            <col width="5%">  <col width="7%">  <col width="25%"> <col width="*">   
            <col width="10%"> <col width="10%"> <col width="12%"> <col width="8%">  
        </colgroup>
        <thead>
            <tr>
                <th>선택</th> <th>번호</th>
                <th>상품명</th>
                <th>리뷰내용</th>
                <th>평점</th>
                <th>작성자</th>
                <th>작성일</th>
                <th>관리</th>
            </tr>
        </thead>
        <tbody>
            <c:if test="${empty requestScope.reviewList}">
                <tr>
                    <td colspan="8" style="padding: 50px; color:#777;">등록된 리뷰가 없습니다.</td>
                </tr>
            </c:if>

            <c:forEach var="rvo" items="${requestScope.reviewList}" varStatus="status">
                <tr>
                    <td>
                        <input type="checkbox" name="reviewno" value="${rvo.reviewno}">
                    </td>
                    
                    <%-- 번호 출력 (오름차순 계산값) --%>
                    <td>${requestScope.startIter + status.index}</td>
                    
                    <td class="col-product">${rvo.productname}</td>
                    <td class="col-content">${rvo.reviewcontent}</td>
                    
                    <td>
                        <div class="star-rating">
                           <c:forEach begin="1" end="${rvo.rating}">★</c:forEach>
                        </div>
                    </td>
                    
                    <td>${rvo.name}</td>
                    <td>${rvo.writedate}</td>
                    
                    <td>
                        <button type="button" class="btn-hide">숨김</button>
                    </td>
                </tr>
            </c:forEach>
        </tbody>
      </table>

      <div class="pagination">
        ${requestScope.pageBar}
      </div>

    </section>
  </div>
</main>

<jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>