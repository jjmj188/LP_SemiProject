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
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<style>
    /* [중요] 메뉴바 스타일 강제 적용 */
    .admin-menu {
        display: flex;
        gap: 20px;
        border-bottom: 1px solid #ddd;
        padding: 10px 0;
        margin-bottom: 20px;
        background: #fff;
    }
    .admin-menu a {
        text-decoration: none;
        color: #555 !important;
        font-weight: bold;
        font-size: 16px;
        padding-bottom: 5px;
        display: inline-block;
    }
    .admin-menu a:hover {
        color: #000 !important;
    }
    .admin-menu a.active {
        color: #000 !important;
        border-bottom: 2px solid #000;
    }

    /* === 상품 리스트 스타일 === */
    .product-control {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }
    .control-left { font-size: 14px; color: #333; }
    
    .btn-add {
        background: #333;
        color: #fff; border: none; padding: 8px 15px; cursor: pointer; font-weight: bold;
    }
    .btn-delete {
        background: #d9534f; color: #fff; border: none;
        padding: 6px 12px; cursor: pointer; font-size: 13px; margin-bottom: 10px;
    }

    .product-list { display: flex; flex-direction: column; gap: 10px; }
    
    .product-item {
        display: flex;
        align-items: center; border: 1px solid #eee; padding: 15px; border-radius: 5px; background: #fff;
    }
    .product-item input[type=checkbox] { margin-right: 15px; }
    .product-item img { margin-right: 20px; border: 1px solid #ddd; }
    
    .product-info { flex: 1; }
    .product-info p { margin: 3px 0; }
    .artist-en { color: #555; font-size: 14px; }
    .artist-kr { font-weight: bold; font-size: 16px; color: #333; }
    .price { font-weight: bold; color: #000; margin-top: 5px; }
    
    .product-btns { display: flex; gap: 5px; }
    .product-btns button {
        padding: 5px 10px;
        border: 1px solid #ccc; background: #fff; cursor: pointer; font-size: 12px;
    }
    .btn-remove { color: #d9534f; border-color: #d9534f !important; }

    /* 페이징 */
    .pagination { text-align: center; margin-top: 30px; }
    .pagination a {
        display: inline-block; padding: 5px 10px;
        border: 1px solid #ddd; color: #555; text-decoration: none; margin: 0 2px;
    }
    .pagination a.active { background: #333; color: #fff; border-color: #333; }

    /* === 모달 스타일 === */
    .modal-overlay {
        display: none;
        position: fixed; top: 0; left: 0; width: 100%; height: 100%;
        background: rgba(0,0,0,0.5); justify-content: center; align-items: center; z-index: 1000;
    }
    .modal-window {
        background: #fff; width: 500px; border-radius: 5px;
        overflow: hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.3);
    }
    .modal-header {
        padding: 15px;
        background: #f1f1f1; border-bottom: 1px solid #ddd; display: flex; justify-content: space-between; align-items: center;
    }
    .modal-header h3 { margin: 0; font-size: 18px; }
    .btn-close-modal { border: none; background: none; font-size: 24px; cursor: pointer; }
    
    .modal-body {
        padding: 20px;
        max-height: 60vh; overflow-y: auto;
    }
    
    .form-group { margin-bottom: 15px; }
    .form-group label { display: block; margin-bottom: 5px; font-weight: bold; font-size: 13px; }
    .input-text { width: 100%; padding: 8px; border: 1px solid #ddd; box-sizing: border-box; }
    .input-file { width: 100%; }
    
    /* 트랙 리스트 스타일 */
    .track-list-box { background: #f9f9f9; padding: 10px; border: 1px solid #ddd; margin-bottom: 5px; }
    .track-item { display: flex; gap: 5px; margin-bottom: 5px; align-items: center; }
    .track-item input { flex: 1; }
    .btn-add-track { padding: 5px 10px; background: #555; color: #fff; border: none; cursor: pointer; font-size: 12px; border-radius: 3px; }
    .btn-remove-track { padding: 5px 8px; background: #fff; border: 1px solid #ccc; color: red; cursor: pointer; font-weight: bold; border-radius: 3px; }

    .modal-footer {
        padding: 15px;
        border-top: 1px solid #ddd; text-align: right; background: #f9f9f9;
    }
    .btn-submit-modal { background: #333; color: #fff; padding: 8px 20px; border: none; cursor: pointer; }
    .btn-cancel-modal { background: #fff; border: 1px solid #ccc; padding: 8px 15px; margin-right: 5px; cursor: pointer; }
</style>
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
        <button class="btn-add" onclick="openRegisterModal()">상품등록</button>
      </div>

      <form name="deleteFrm">
          <div class="product-action">
            <button type="button" class="btn-delete" onclick="goDelete()">선택 삭제</button>
          </div>

          <div class="product-list">
            <c:if test="${empty requestScope.productList}">
                <div style="padding: 50px; text-align: center;">등록된 상품이 없습니다.</div>
            </c:if>

            <c:forEach var="pvo" items="${requestScope.productList}">
                <div class="product-item">
                  <input type="checkbox" name="pseq" value="${pvo.productno}">
                  
                  <%-- [수정] 이미지 경로에 /images/productimg/ 추가 --%>
                  <img src="<%= ctxPath%>/images/productimg/${pvo.productimg}" 
                       onerror="this.src='<%= ctxPath%>/images/no_image.png'" 
                       alt="${pvo.productname}" style="width: 80px; height: 80px; object-fit: cover;">
                       
                  <div class="product-info">
                    <p class="artist-en" style="font-weight: bold;">[${pvo.categoryname}]</p>
                    <p class="artist-kr">${pvo.productname}</p>
                    <p class="price"><fmt:formatNumber value="${pvo.price}" pattern="#,###" />원</p>
                    <p class="stock" style="font-size: 12px; color: #888;">재고: ${pvo.stock} | 포인트: ${pvo.point}</p>
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
          
          <%-- 페이지바 출력 --%>
          <div class="pagination">
          	${requestScope.pageBar}
          </div>
          
      </form>
    </section>
  </div>
</main>

<%-- 모달 (등록/수정 공용) --%>
<div id="productModal" class="modal-overlay">
  <div class="modal-window">
    <div class="modal-header">
      <h3 id="modalTitle">상품 등록</h3>
      <button class="btn-close-modal" onclick="closeModal()">×</button>
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
            <p id="currentImgText" style="font-size:12px; color:blue; display:none;">(기존 이미지 유지시 선택 안함)</p>
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
            <textarea name="productdesc" id="modalDesc" class="input-text" style="height: 100px; resize: none;"></textarea>
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
          <button type="button" class="btn-cancel-modal" onclick="closeModal()">취소</button>
          <button type="submit" class="btn-submit-modal" id="modalSubmitBtn">등록하기</button>
        </div>
    </form>
  </div>
</div>

<jsp:include page="/WEB-INF/footer2.jsp" />

<script>
$(document).ready(function(){
    // 전체선택 체크박스
    $("#checkAll").click(function(){
        $("input[name='pseq']").prop("checked", $(this).prop("checked"));
    });
    
    $("input[name='pseq']").click(function(){
        var total = $("input[name='pseq']").length;
        var checked = $("input[name='pseq']:checked").length;
        $("#checkAll").prop("checked", total == checked);
    });
});

// 선택 삭제
function goDelete() {
    if($("input[name='pseq']:checked").length == 0) {
        alert("삭제할 상품을 선택하세요.");
        return;
    }
    if(confirm("정말 삭제하시겠습니까? (관련 트랙 정보도 모두 삭제됩니다)")) {
        var frm = document.deleteFrm;
        // [수정] 컨트롤러 분기 처리를 위해 mode 파라미터 추가
        frm.action = "<%= ctxPath%>/admin/admin_product.lp?mode=delete"; 
        frm.method = "POST";
        frm.submit();
    }
}

// 개별 삭제
function goDeleteOne(pno) {
    if(confirm("이 상품을 삭제하시겠습니까?")) {
        var form = document.createElement("form");
        form.method = "POST";
        // [수정] 컨트롤러 분기 처리를 위해 mode 파라미터 추가
        form.action = "<%= ctxPath%>/admin/admin_product.lp?mode=delete";
        var input = document.createElement("input");
        input.type = "hidden";
        input.name = "pseq";
        input.value = pno;
        form.appendChild(input);
        document.body.appendChild(form);
        form.submit();
    }
}

// 등록 모달
function openRegisterModal() {
    document.productFrm.reset();
    document.getElementById("modalProductNo").value = "";
    document.getElementById("trackContainer").innerHTML = '<div class="track-item"><input type="text" name="track_title" class="input-text" placeholder="1번 트랙 제목"></div>';
    
    document.getElementById("modalTitle").innerText = "상품 등록";
    document.getElementById("modalSubmitBtn").innerText = "등록하기";
    document.getElementById("currentImgText").style.display = "none";
    document.getElementById("trackSection").style.display = "block";
    
    // [수정] 컨트롤러 분기 처리를 위해 mode=register 추가
    document.productFrm.action = "<%= ctxPath%>/admin/admin_product.lp?mode=register";
    document.getElementById('productModal').style.display = 'flex';
}

// 수정 모달
function openEditModal(btn) {
    var pno = btn.getAttribute("data-pno");
    var cno = btn.getAttribute("data-cno");
    var name = btn.getAttribute("data-name");
    var price = btn.getAttribute("data-price");
    var stock = btn.getAttribute("data-stock");
    var point = btn.getAttribute("data-point");
    var url = btn.getAttribute("data-url");
    var desc = btn.getAttribute("data-desc");

    document.getElementById("modalProductNo").value = pno;
    document.getElementById("modalCategory").value = cno;
    document.getElementById("modalName").value = name;
    document.getElementById("modalPrice").value = price;
    document.getElementById("modalStock").value = stock;
    document.getElementById("modalPoint").value = point;
    document.getElementById("modalUrl").value = url;
    document.getElementById("modalDesc").value = desc;

    document.getElementById("modalTitle").innerText = "상품 수정";
    document.getElementById("modalSubmitBtn").innerText = "수정하기";
    document.getElementById("currentImgText").style.display = "block";
    document.getElementById("trackSection").style.display = "none";
    
    // [수정] 컨트롤러 분기 처리를 위해 mode=edit 추가
    document.productFrm.action = "<%= ctxPath%>/admin/admin_product.lp?mode=edit";
    document.getElementById('productModal').style.display = 'flex';
}

function closeModal() {
    document.getElementById('productModal').style.display = 'none';
}

function addTrackField() {
    const container = document.getElementById("trackContainer");
    const count = container.children.length + 1;
    const div = document.createElement("div");
    div.className = "track-item";
    div.innerHTML = `<input type="text" name="track_title" class="input-text" placeholder="\${count}번 트랙 제목"><button type="button" class="btn-remove-track" onclick="this.parentElement.remove()">x</button>`;
    container.appendChild(div);
}
</script>

</body>
</html>