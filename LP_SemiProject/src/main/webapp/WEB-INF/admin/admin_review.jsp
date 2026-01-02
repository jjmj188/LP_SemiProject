<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>

  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_review.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
  <main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" >회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp" >상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp" >주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp" class="active">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>리뷰 관리</h2>

      <div class="review-control">
        <div class="control-left">
          <label>
            <input type="checkbox">
            전체 선택
          </label>
          <span class="selected-count">(0)</span>
        </div>

        <div class="control-right">
          <button class="btn-delete">선택 삭제</button>
        </div>
      </div>

      <table class="review-table">
        <thead>
          <tr>
            <th></th>
            <th>상품명</th>
            <th>리뷰내용</th>
            <th>평점</th>
            <th>작성자</th>
            <th>작성일</th>
            <th>관리</th>
          </tr>
        </thead>

        <tbody>
          <tr>
            <td><input type="checkbox"></td>
            <td class="product-name">LP - Abbey Road</td>
            <td class="review-content">
              음질이 정말 좋고 포장도 깔끔했어요!
            </td>
            <td>⭐⭐⭐⭐⭐</td>
            <td>김소라</td>
            <td>2025-01-12</td>
            <td>
              <button class="btn-small">숨김</button>
            </td>
          </tr>

          <tr>
            <td><input type="checkbox"></td>
            <td class="product-name">LP - Kind of Blue</td>
            <td class="review-content">
              생각보다 배송이 빨라서 만족합니다.
            </td>
            <td>⭐⭐⭐⭐</td>
            <td>홍길동</td>
            <td>2025-01-10</td>
            <td>
              <button class="btn-small">숨김</button>
            </td>
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