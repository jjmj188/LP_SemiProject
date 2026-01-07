<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
	String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 리뷰 관리</title>
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_review.css">
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
        <div class="control-left">
          <label>
            <input type="checkbox" id="checkAll">
            전체 선택
          </label>
        </div>

        <div class="control-right">
          <button class="btn-delete" onclick="alert('준비중인 기능입니다.')">선택 삭제</button>
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
          <c:if test="${empty requestScope.reviewList}">
              <tr>
                  <td colspan="7" style="text-align: center; padding: 50px; color: #666;">
                      등록된 리뷰가 없습니다.
                  </td>
              </tr>
          </c:if>

          <c:forEach var="rvo" items="${requestScope.reviewList}">
              <tr>
                <td>
                    <input type="checkbox" name="reviewno" value="${rvo.reviewno}">
                </td>
                
                <td class="product-name">
                    ${rvo.productname}
                </td>
                
                <td class="review-content" style="text-align: left;">
                  ${rvo.reviewcontent}
                </td>
                
                <td>
                   <c:forEach begin="1" end="${rvo.rating}">
                       ⭐
                   </c:forEach>
                </td>
                
                <td>${rvo.name}</td>
                
                <td>${rvo.writedate}</td>
                
                <td>
                  <button class="btn-small" onclick="alert('준비중인 기능입니다.')">숨김</button>
                </td>
              </tr>
          </c:forEach>
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

<script>
    const checkAll = document.getElementById('checkAll');
    const checkboxes = document.getElementsByName('reviewno');

    if(checkAll) {
        checkAll.addEventListener('change', function() {
            for(let box of checkboxes) {
                box.checked = this.checked;
            }
        });
    }
</script>

</body>
</html>