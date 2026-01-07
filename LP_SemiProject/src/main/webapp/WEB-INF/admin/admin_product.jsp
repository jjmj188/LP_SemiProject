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
<title>관리자 페이지 - 상품관리</title>
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_product.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
</head>
<body>

<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>

<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp">회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp" class="active">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">

      <div class="product-control">
        <div class="control-left">
          <strong>전체관리</strong>
          <label>
            <input type="checkbox" id="checkAll"> 전체선택
          </label>
        </div>

        <button class="btn-add" onclick="openModal()">상품등록</button>
      </div>

      <div class="product-action">
        <button class="btn-delete">선택 삭제</button>
      </div>

      <div class="product-list">
        
        <c:if test="${empty requestScope.productList}">
            <div style="text-align: center; padding: 50px; width: 100%; color: #666;">
                등록된 상품이 없습니다.
            </div>
        </c:if>

        <c:forEach var="pvo" items="${requestScope.productList}">
            <div class="product-item">
              <input type="checkbox" name="pseq" value="${pvo.productno}">
              
              <img src="<%= ctxPath%>/images/productimg/${pvo.productimg}" 
                   onerror="this.src='<%= ctxPath%>/images/no_image.png'" 
                   alt="${pvo.productname}"
                   style="width: 80px; height: 80px; object-fit: cover;">
              <div class="product-info">
                <p class="artist-en">[${pvo.categoryname}]</p>
                <p class="artist-kr">${pvo.productname}</p>
                <p class="price">
                    <fmt:formatNumber value="${pvo.price}" pattern="#,###" />원
                </p>
                <p class="stock" style="font-size: 12px; color: #888;">
                    재고: ${pvo.stock}개 | 포인트: ${pvo.point}P
                </p>
              </div>

              <div class="product-btns">
                <button class="btn-edit">수정</button>
                <button class="btn-remove">삭제</button>
              </div>
            </div>
        </c:forEach>

      </div>

      <div class="pagination">
        <a href="#" class="prev">&lsaquo;</a>
        <a href="#" class="active">1</a>
        <a href="#" class="next">&rsaquo;</a>
      </div>

    </section>
  </div>
</main>


<div id="productModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3>상품 등록</h3>
      <button class="btn-close-modal" onclick="closeModal()">×</button>
    </div>
    
    <form name="productRegisterFrm" action="<%= ctxPath%>/admin/productRegister.lp" 
          method="post" enctype="multipart/form-data">
        
        <div class="modal-body">
          <div class="form-group">
            <label>카테고리</label>
            <select name="fk_categoryno" class="input-text">
              <option value="">카테고리 선택</option>
              <option value="1">POP</option>
              <option value="2">ROCK</option>
              <option value="3">JAZZ</option>
              <option value="4">CLASSIC</option>
              <option value="5">ETC</option>
            </select>
          </div>

          <div class="form-group">
            <label>제품명</label>
            <input type="text" name="productname" placeholder="제품명을 입력하세요" class="input-text">
          </div>

          <div class="form-group">
            <label>이미지</label>
            <input type="file" name="productimg" class="input-file">
          </div>

          <div class="form-group">
            <label>가격</label>
            <input type="number" name="price" placeholder="숫자만 입력" class="input-text">
          </div>

          <div class="form-group">
            <label>재고량</label>
            <input type="number" name="stock" value="20" class="input-text">
          </div>

          <div class="form-group">
            <label>적립 포인트</label>
            <input type="number" name="point" value="10" class="input-text">
          </div>

          <div class="form-group">
            <label>관련 영상 (YouTube URL)</label>
            <input type="text" name="youtubeurl" class="input-text">
          </div>

          <div class="form-group">
            <label>제품 설명</label>
            <textarea name="productdesc" class="input-text" style="height: 100px; resize: none;"></textarea>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn-cancel-modal" onclick="closeModal()">취소</button>
          <button type="submit" class="btn-submit-modal">등록하기</button>
        </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/footer2.jsp" />

<script src="<%= ctxPath%>/js/admin/admin_product.js"></script>

</body>
</html>