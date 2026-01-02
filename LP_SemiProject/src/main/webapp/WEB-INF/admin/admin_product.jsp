<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>

  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_product.css">
  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">

<!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" >회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp" class="active">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp" >주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">

      <div class="product-control">
        <div class="control-left">
          <strong>전체관리</strong>
          <label>
            <input type="checkbox"> 전체선택
          </label>
        </div>

        <button class="btn-add">상품등록</button>
      </div>

      <div class="product-action">
        <button class="btn-delete">선택 삭제</button>
      </div>

      <div class="product-list">

        <div class="product-item">
          <input type="checkbox">
          <img src="<%= ctxPath%>/images/리사.png" alt="Lisa LP">

          <div class="product-info">
            <p class="artist-en">LISA</p>
            <p class="artist-kr">리사</p>
            <p class="price">₩42,000</p>
          </div>

          <div class="product-btns">
            <button class="btn-edit">수정</button>
            <button class="btn-remove">삭제</button>
          </div>
        </div>

        <div class="product-item">
          <input type="checkbox">
          <img src="<%= ctxPath%>/images/로제.png" alt="Rose LP">

          <div class="product-info">
            <p class="artist-en">ROSÉ</p>
            <p class="artist-kr">로제</p>
            <p class="price">₩40,000</p>
          </div>

          <div class="product-btns">
            <button class="btn-edit">수정</button>
            <button class="btn-remove">삭제</button>
          </div>
        </div>

      </div>

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

<div id="productModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3>상품 등록</h3>
      <button class="btn-close-modal">×</button>
    </div>
    
 <div class="modal-body">
      <div class="form-group">
        <label>카테고리</label>
        <select class="input-text">
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
        <input type="text" placeholder="제품명을 입력하세요 (예: LISA - LALISA)" class="input-text">
      </div>

      <div class="form-group">
        <label>이미지</label>
        <input type="file" class="input-file">
      </div>

      <div class="form-group">
        <label>가격</label>
        <input type="number" placeholder="숫자만 입력 (예: 42000)" class="input-text">
      </div>

      <div class="form-group">
        <label>재고량</label>
        <input type="number" placeholder="수량 입력 (기본: 20)" value="20" class="input-text">
      </div>

      <div class="form-group">
        <label>발매일</label>
        <input type="date" class="input-text">
      </div>

      <div class="form-group">
        <label>적립 포인트</label>
        <input type="number" placeholder="기본: 10" value="10" class="input-text">
      </div>

      <div class="form-group">
        <label>관련 영상 (YouTube URL)</label>
        <input type="text" placeholder="https://youtube.com/..." class="input-text">
      </div>

      <div class="form-group">
        <label>제품 설명</label>
        <textarea placeholder="제품 상세 설명을 입력하세요" class="input-text" style="height: 100px; resize: none;"></textarea>
      </div>
    </div>

    <div class="modal-footer">
      <button class="btn-cancel-modal">취소</button>
      <button class="btn-submit-modal">등록하기</button>
    </div>
  </div>
</div>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
<script src="<%= ctxPath%>/js/admin/admin_product.js"></script>