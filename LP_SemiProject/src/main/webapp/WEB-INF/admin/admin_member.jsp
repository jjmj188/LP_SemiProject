<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>

  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">

  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_member.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
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

      <div class="admin-search">
        <input type="text" placeholder="아이디 또는 이름 검색">
        <button>검색</button>
      </div>

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
          <tr>
            <td>1</td>
            <td>seoulvinyl</td>
            <td>김소라</td>
            <td>seoul@vinyl.com</td>
            <td>2025-01-01</td>
            <td><button class="btn-delete">삭제</button></td>
          </tr>
        </tbody>
      </table>

      <div class="pagination">
        <a href="#" class="prev">&lsaquo;</a>
        <a href="#" class="active">1</a>
        <a href="#">2</a>
        <a href="#">3</a>
        <a href="#">4</a>
        <a href="#">5</a>
        <a href="#" class="next">&rsaquo;</a>
      </div>

    </section>

  </div>
</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
