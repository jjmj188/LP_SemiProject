<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>${pDto.productname} | LP Shop</title>

    <link rel="stylesheet" href="<%= ctxPath %>/css/common/header.css">
    <link rel="stylesheet" href="<%= ctxPath %>/css/common/footer.css">
    <link rel="stylesheet" href="<%= ctxPath %>/css/product/product.css">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">
</head>

<body>

    <jsp:include page="header1.jsp" />

    <main class="product-container">

        <div class="product-image">
            <img src="<%= ctxPath %>/${pDto.productimg}" alt="${pDto.productname}">
        </div>

        <div class="product-info">
            <h1>${pDto.productname}</h1>
            
            <p class="price" id="totalPrice">
                ₩ <fmt:formatNumber value="${pDto.price}" pattern="#,###"/>
            </p>
            
            <div class="benefit">
                <p class="discount">
                    할인 적용 시 <b>₩ <fmt:formatNumber value="${pDto.price * 0.9}" pattern="#,###"/></b> (10%)
                </p>
                <p class="point">적립 포인트 <b><fmt:formatNumber value="${pDto.point}" pattern="#,###"/>P</b></p>
            </div>
            
            <p class="delivery">배송비 <b>2,500원</b></p>

            <div class="quantity">
                <button type="button" onclick="changeQty(-1)">−</button>
                <span id="qty">1</span>
                <button type="button" onclick="changeQty(1)">+</button>
            </div>

            <div class="wishlist">
                <button type="button" id="wishBtn" onclick="toggleWish()">
                    <i class="fa-solid fa-heart"></i> 찜하기
                </button>
            </div>

            <div class="action-buttons">
                <button type="button" class="buy" onclick="goOrder()">구매하기</button>
                 
                 <form id="cartForm"  style="display:inline;">
			        <input type="hidden" name="productno" value="${pDto.productno}">
			        <input type="hidden" id="cartQty" name="qty" value="1">
			        <button type="button" class="cart" onclick="goCart()">장바구니</button>
   				 </form>


   				 
            </div>
        </div>

    </main>

    <section class="product-description">
        <h2>앨범 소개</h2>
        <p class="desc-text" style="white-space: pre-wrap;">${pDto.productdesc}</p>
    </section>
    
    <div class="container-top">
        <div class="album">
          <div class="cover">
             <img src="<%= ctxPath %>/${pDto.productimg}" alt="Album Cover">
          </div>
          <div class="vinyl">
             <div class="vinyl-cover" style="background-image: url('<%= ctxPath %>/${pDto.productimg}');"></div>
          </div>
       </div>
    </div>

    <section class="track-list">
        <h2>TRACK LIST</h2>

        <ol>
            <c:if test="${not empty requestScope.trackList}">
                <c:forEach var="track" items="${requestScope.trackList}">
                    <li>${track.tracktitle}</li>
                </c:forEach>
            </c:if>
            
            <c:if test="${empty requestScope.trackList}">
                <li>등록된 트랙 정보가 없습니다.</li>
            </c:if>
        </ol>
    </section>

    <c:if test="${not empty pDto.youtubeurl}">
        <section class="preview-video">
            <h2>미리 듣기</h2>
    
            <c:set var="videoUrl" value="${pDto.youtubeurl}" />
            <c:set var="youtubeId" value="" />
            
            <c:choose>
                <%-- 케이스 A: 긴 주소 (youtube.com/watch?v=ID) --%>
                <c:when test="${fn:contains(videoUrl, 'v=')}">
                    <c:set var="youtubeId" value="${fn:substringAfter(videoUrl, 'v=')}" />
                </c:when>
                <%-- 케이스 B: 짧은 주소 (youtu.be/ID) - 지금 회원님 상황! --%>
                <c:when test="${fn:contains(videoUrl, 'youtu.be/')}">
                    <c:set var="youtubeId" value="${fn:substringAfter(videoUrl, 'youtu.be/')}" />
                </c:when>
                <%-- 케이스 C: 임베드 주소 (youtube.com/embed/ID) --%>
                 <c:when test="${fn:contains(videoUrl, 'embed/')}">
                    <c:set var="youtubeId" value="${fn:substringAfter(videoUrl, 'embed/')}" />
                </c:when>
            </c:choose>
            
            <c:if test="${fn:contains(youtubeId, '&')}">
                <c:set var="youtubeId" value="${fn:substringBefore(youtubeId, '&')}" />
            </c:if>
            <c:if test="${fn:contains(youtubeId, '?')}">
                <c:set var="youtubeId" value="${fn:substringBefore(youtubeId, '?')}" />
            </c:if>
    
            <div class="video">
                <iframe
                    src="https://www.youtube.com/embed/${youtubeId}"
                    title="${pDto.productname}"
                    allowfullscreen>
                </iframe>
            </div>
        </section>
    </c:if>

    <section class="reviews">
        <h2>Reviews</h2>
        <div class="review-item">
            <div class="review-header">
                <span class="user-id">test_user</span>
                <div class="review-rating">
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <i class="fa-solid fa-star"></i>
                    <span class="score">5.0 / 5.0</span>
                </div>
            </div>
            <p class="review-text">
                배송도 빠르고 노래도 너무 좋아요! (임시 리뷰입니다)
            </p>
        </div>
        <div class="review-more">
            <button type="button">전체보기</button>
        </div>
    </section>

    <jsp:include page="footer1.jsp" />

<script>
     let qty = 1;
     const productNo = "${pDto.productno}"; // 현재 상품 번호
     
     const unitPrice = ${pDto.price}; 
     const isLogin = ${not empty sessionScope.loginuser};
     
     const loginUrl = "<%= ctxPath%>/login/login.lp";
     
     function changeQty(num) {
         qty += num;
         if (qty < 1) qty = 1;
         
         // 재고 체크
         const stock = ${pDto.stock};
         if(qty > stock) {
             alert("죄송합니다. 재고가 " + stock + "개 남았습니다.");
             qty = stock;
         }
         
         // 수량 화면 업데이트
         document.getElementById("qty").innerText = qty;

         // 가격 화면 업데이트 (단가 * 수량)
         const total = unitPrice * qty;
         document.getElementById("totalPrice").innerText = "₩ " + total.toLocaleString();
     }

  // 찜하기
     function toggleWish() {
         if(!isLogin) {
             alert("로그인이 필요한 서비스입니다.");
             location.href = loginUrl;
             return;
         }
         alert("찜 목록에 추가합니다 (기능 구현 예정)");
     }
     
     // 바로 구매하기 (POST 전송)
     function goOrder() {
         if(!isLogin) {
             alert("로그인이 필요한 서비스입니다.");
             location.href = loginUrl;
             return;
         }
         // 구매 페이지로 POST 전송
         goPost("<%= ctxPath%>/order/buy.lp");
     }
     
<<<<<<< HEAD
=======
function goCart() {
        const choice = confirm("장바구니에 담으시겠습니까?");
        if(!choice) return;

        document.getElementById("cartQty").value = qty;
       
        
     // 전송 (POST)
      	const frm = document.getElementById("cartForm");
      	frm.method = "post";
      	frm.action = "/LP_SemiProject/order/cartAdd.lp";
      	frm.submit();
      	
      	
    }
>>>>>>> refs/heads/joung
     
 </script>
   

</body>
</html>