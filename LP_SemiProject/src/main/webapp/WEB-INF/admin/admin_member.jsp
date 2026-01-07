<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
	String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_member.css">
  
<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>
  
<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" class="active">회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>회원관리</h2>

      <form name="memberSearchFrm" action="<%= ctxPath%>/admin/admin_member.lp" method="get">
          <div class="admin-search">
            <input type="text" name="searchWord" value="${requestScope.searchWord}" placeholder="아이디 또는 이름 검색">
            <button type="submit">검색</button>
          </div>
      </form>
      <table class="admin-table">
        <thead>
          <tr>
            <th>회원번호</th>
            <th>아이디</th>
            <th>이름</th>
            <th>이메일</th>
            <th>가입일</th>
            <th>관리</th>
          </tr>
        </thead>
        
        <tbody>
          <c:if test="${empty requestScope.memberList}">
              <tr>
                  <td colspan="6" style="text-align: center; padding: 20px;">가입된 회원이 없습니다.</td>
              </tr>
          </c:if>

          <c:if test="${not empty requestScope.memberList}">
              <c:forEach var="mvo" items="${requestScope.memberList}">
                  <tr>
                    <td>${mvo.userseq}</td>
                    <td>${mvo.userid}</td>
                    <td>${mvo.name}</td>
                    <td>${mvo.email}</td>
                    <td>${mvo.registerday}</td>
                    <td><button class="btn-delete" onclick="alert('삭제 기능은 구현 중입니다.')">삭제</button></td>
                  </tr>
              </c:forEach>
          </c:if>
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

<jsp:include page="/WEB-INF/footer2.jsp" />