<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 상품관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_product.css">

<script>const ctxPath = "<%= ctxPath %>";</script>
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath%>/js/admin/admin_product.js"></script>

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
          <label><input type="checkbox" id="checkAll"> 전체선택</label>
        </div>
        <button class="btn-add" id="btnOpenRegister">상품등록</button>
      </div>

      <form name="deleteFrm">
          <div class="product-action">
            <button type="button" class="btn-delete" onclick="goDelete()">선택 삭제</button>
          </div>

          <div class="product-list">
            <c:if test="${empty requestScope.productList}">
                <div class="empty-msg">등록된 상품이 없습니다.</div>
            </c:if>

            <c:forEach var="pvo" items="${requestScope.productList}">
                <div class="product-item">
                  <input type="checkbox" name="pseq" value="${pvo.productno}">
                  
                  <img src="<%= ctxPath%>${pvo.productimg}" 
                       onerror="this.src='<%= ctxPath%>/images/no_image.png'" 
                       alt="${pvo.productname}">
                       
                  <div class="product-info">
                    <p class="artist-en">[${pvo.categoryname}]</p>
                    <p class="artist-kr">${pvo.productname}</p>
                    <p class="price"><fmt:formatNumber value="${pvo.price}" pattern="#,###" />원</p>
                    <p class="stock">재고: ${pvo.stock} | 포인트: ${pvo.point}</p>
                  </div>

                  <div class="product-btns">
                    <button type="button" class="btn-edit"
                            data-pno="${pvo.productno}"
                            data-cno="${pvo.fk_categoryno}"
                            data-name="${pvo.productname}"
                            data-price="${pvo.price}"
                            data-stock="${pvo.stock}"
                            data-point="${pvo.point}"
                            data-url="${pvo.youtubeurl}"
                            data-desc="${pvo.productdesc}"
                            onclick="openEditModal(this)">수정</button>
                            
                    <button type="button" class="btn-remove" onclick="goDeleteOne('${pvo.productno}')">삭제</button>
                  </div>
                </div>
            </c:forEach>
          </div>
          
          <div class="pagination">
              ${requestScope.pageBar}
          </div>
          
      </form>
    </section>
  </div>
</main>

<div id="productModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3 id="modalTitle">상품 등록</h3>
      <button type="button" class="btn-close-modal" id="btnCloseModal">×</button>
    </div>
    
    <form name="productFrm" method="post" enctype="multipart/form-data">
        <input type="hidden" name="productno" id="modalProductNo"> 
        
        <div class="modal-body">
          <div class="form-group">
            <label>카테고리</label>
            <select name="fk_categoryno" id="modalCategory" class="input-text">
              <option value="1">POP</option>
              <option value="2">ROCK</option>
              <option value="3">JAZZ</option>
              <option value="4">CLASSIC</option>
              <option value="5">ETC</option>
            </select>
          </div>
          <div class="form-group">
            <label>제품명</label>
            <input type="text" name="productname" id="modalName" class="input-text">
          </div>
          <div class="form-group">
            <label>이미지</label>
            <input type="file" name="productimg" class="input-file">
            <p id="currentImgText">(기존 이미지 유지시 선택 안함)</p>
          </div>
          <div class="form-group">
            <label>가격</label>
            <input type="number" name="price" id="modalPrice" class="input-text">
          </div>
          <div class="form-group">
            <label>재고량</label>
            <input type="number" name="stock" id="modalStock" class="input-text">
          </div>
          <div class="form-group">
            <label>적립 포인트</label>
            <input type="number" name="point" id="modalPoint" class="input-text">
          </div>
          <div class="form-group">
            <label>관련 영상 (YouTube URL)</label>
            <input type="text" name="youtubeurl" id="modalUrl" class="input-text">
          </div>
          <div class="form-group">
            <label>앨범 소개 (제품 설명)</label>
            <textarea name="productdesc" id="modalDesc" class="input-text desc-area"></textarea>
          </div>
          
          <div class="form-group" id="trackSection">
            <label>수록곡 리스트 (Track List)</label>
            <div class="track-list-box" id="trackContainer">
                <div class="track-item"><input type="text" name="track_title" class="input-text" placeholder="1번 트랙 제목"></div>
            </div>
            <button type="button" class="btn-add-track" onclick="addTrackField()">+ 트랙 추가</button>
          </div>
        </div>

        <div class="modal-footer">
          <button type="button" class="btn-cancel-modal" id="btnCancelModal">취소</button>
          <button type="submit" class="btn-submit-modal" id="modalSubmitBtn">등록하기</button>
        </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>