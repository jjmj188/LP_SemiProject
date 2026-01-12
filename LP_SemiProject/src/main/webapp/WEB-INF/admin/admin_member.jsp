<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 회원관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_member.css">

<script>const ctxPath = "<%= ctxPath %>";</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_member.js"></script>

</head>
<body>

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
      <h2>회원 관리 <span style="font-size:14px; color:#999; margin-left:10px;">(총 ${requestScope.totalCount}명)</span></h2>

      <div class="member-control">
        <form name="searchFrm" class="search-box" onsubmit="return false;">
            <select name="searchType">
                <option value="userid" ${requestScope.searchType == 'userid' ? 'selected' : ''}>아이디</option>
                <option value="name" ${requestScope.searchType == 'name' ? 'selected' : ''}>성명</option>
            </select>
            <input type="text" name="searchWord" value="${requestScope.searchWord}" placeholder="검색어를 입력하세요">
            <button type="button" class="btn-search">검색</button>
        </form>

        <button type="button" class="btn-delete" onclick="goDelete()">회원 탈퇴</button>
      </div>

      <form name="memberFrm">
          <table class="member-table">
            <colgroup>
                <col width="5%">  <col width="8%">  <col width="15%"> <col width="10%"> <col width="20%"> <col width="15%"> <col width="15%"> <col width="10%"> 
            </colgroup>
            <thead>
              <tr>
                <th><input type="checkbox" id="checkAll"></th>
                <th>번호</th>
                <th>아이디</th>
                <th>성명</th>
                <th>이메일</th>
                <th>전화번호</th>
                <th>가입일자</th>
                <th>상태</th>
              </tr>
            </thead>

            <tbody>
              <%-- 회원이 없을 경우 --%>
              <c:if test="${empty requestScope.memberList}">
                  <tr>
                      <td colspan="8" style="padding: 50px; color: #777;">검색된 회원이 없습니다.</td>
                  </tr>
              </c:if>

              <%-- 회원 리스트 반복 출력 --%>
              <c:forEach var="mvo" items="${requestScope.memberList}" varStatus="status">
                  <tr>
                    <td>
                        <%-- 관리자 계정(admin)은 삭제 불가하도록 체크박스 숨김 --%>
                        <c:if test="${mvo.userid != 'admin'}">
                            <input type="checkbox" name="userid" value="${mvo.userid}">
                        </c:if>
                    </td>
                    
                    <%-- [수정 완료] 오름차순 번호 출력 (시작값 + 현재인덱스) --%>
                    <td>${requestScope.startIter + status.index}</td>
                    
                    <td>${mvo.userid}</td>
                    <td>${mvo.name}</td>
                    <td>${mvo.email}</td>
                    <td>${mvo.mobile}</td>
                    <td>${mvo.registerday}</td>
                    
                    <td>
                        <c:choose>
                            <c:when test="${mvo.status == 1}">
                                <span class="status-active">활동중</span>
                            </c:when>
                            <c:otherwise>
                                <span class="status-out">탈퇴</span>
                            </c:otherwise>
                        </c:choose>
                    </td>
                  </tr>
              </c:forEach>
            </tbody>
          </table>
      </form>

      <div class="pagination">
        ${requestScope.pageBar}
      </div>

    </section>
  </div>
</main>

<jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>