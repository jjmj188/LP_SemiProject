<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%@ page import="member.model.WishListDAO, member.model.WishListDAO_imple" %>
<%@ page import="member.domain.MemberDTO" %>
<%@ page import="product.domain.ProductDTO" %>

<%
    String ctxPath = request.getContextPath();
    
    boolean isLiked = false;
    MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
    ProductDTO pDto = (ProductDTO) request.getAttribute("pDto");

    if(loginuser != null && pDto != null) {
        WishListDAO wdao = new WishListDAO_imple();
        try {
            int n = wdao.checkWishStatus(loginuser.getUserid(), pDto.getProductno());
            if(n == 1) {
                isLiked = true;
            }
        } catch(Exception e) {
            e.printStackTrace();
        }
    }
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
			        구매시 <b><span id="totalPoint"><fmt:formatNumber value="${pDto.point}" pattern="#,###"/></span>P 적립</b>
			    </p>
			</div>
            
            <p class="delivery">배송비 <b>3,000원</b></p>

            <div class="quantity">
                <button type="button" onclick="changeQty(-1)">−</button>
                <span id="qty">1</span>
                <button type="button" onclick="changeQty(1)">+</button>
            </div>

            <div class="wishlist">
                <button type="button" id="wishBtn" onclick="toggleWish()">
                    <% if(isLiked) { %>
                        <i class="fa-solid fa-heart" id="heartIcon" style="color: red;"></i>
                        <span id="wishText">찜취소</span>
                    <% } else { %>
                        <i class="fa-regular fa-heart" id="heartIcon"></i>
                        <span id="wishText">찜하기</span>
                    <% } %>
                </button>
            </div>

            <div class="action-buttons">
                <c:choose>
                    <%-- 1. 재고가 있을 경우 (기존 버튼 표시) --%>
                    <c:when test="${pDto.stock > 0}">
                    
                    <form id="buyForm" method="post" action="<%= ctxPath %>/order/buy.lp" style="display:inline;">
						  <input type="hidden" name="productno" value="${pDto.productno}">
						  <input type="hidden" name="qty" id="buyQty" value="1">
					</form>
                    
                        <button type="button" class="buy" onclick="goOrder()">구매하기</button>
        
                        <c:choose>
                            <%-- 장바구니 수정 모드 --%>
                            <c:when test="${not empty param.cartno}">
                                <form id="cartUpdateForm" method="post" action="<%= ctxPath %>/order/cartUpdate.lp" style="display:inline;">
                                    <input type="hidden" name="cartno" value="${param.cartno}">
                                    <input type="hidden" name="qty" id="updateQty" value="1">
                                    <button type="submit" class="cart">장바구니 수정</button>
                                </form>
                            </c:when>
                        
                            <%-- 일반 장바구니 담기 모드 --%>
                            <c:otherwise>
                                <form id="cartForm" style="display:inline;">
                                    <input type="hidden" name="productno" value="${pDto.productno}">
                                    <input type="hidden" id="cartQty" name="qty" value="1">
                                    <button type="button" class="cart" onclick="submitCart()">장바구니</button>
                                </form>
                            </c:otherwise>
                        </c:choose>
                    </c:when>
                    
                    <%-- 재고가 0일 경우 (품절 표시) --%>
                    <c:otherwise>
                        <div class="soldout-box">
                            <i class="fa-solid fa-circle-exclamation"></i>
                            <span>일시품절</span>
                        </div>
                    </c:otherwise>
                </c:choose>
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
            <p class="desc-text" style="white-space: pre-wrap;"> 전체 5곡 중 맨 처음 1곡을 들려드립니다</p>
            <c:set var="videoUrl" value="${pDto.youtubeurl}" />
            <c:set var="youtubeId" value="" />
            <c:choose>
                <c:when test="${fn:contains(videoUrl, 'v=')}">
                    <c:set var="youtubeId" value="${fn:substringAfter(videoUrl, 'v=')}" />
                </c:when>
                <c:when test="${fn:contains(videoUrl, 'youtu.be/')}">
                    <c:set var="youtubeId" value="${fn:substringAfter(videoUrl, 'youtu.be/')}" />
                </c:when>
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
                <iframe src="https://www.youtube.com/embed/${youtubeId}" title="${pDto.productname}" allowfullscreen></iframe>
            </div>
        </section>
    </c:if>

    <section class="reviews" id="reviews">
        <h2>Reviews</h2>
        
        <%-- 리뷰 리스트 출력 --%>
        <c:if test="${empty requestScope.reviewList}">
            <div class="review-item" style="justify-content: center; padding: 40px;">
                <p class="review-text" style="color: #999;">등록된 리뷰가 없습니다.</p>
            </div>
        </c:if>

        <c:if test="${not empty requestScope.reviewList}">
            <c:forEach var="review" items="${requestScope.reviewList}">
                <div class="review-item">
                    <div class="review-header">
                        <span class="user-id">${fn:substring(review.userid, 0, 3)}***</span>
                        <div class="review-rating">
                            <c:forEach begin="1" end="${review.rating}">
                                <i class="fa-solid fa-star"></i>
                            </c:forEach>
                            <c:forEach begin="1" end="${5 - review.rating}">
                                <i class="fa-regular fa-star" style="color: #ccc;"></i>
                            </c:forEach>
                            <span class="score">${review.rating}</span>
                        </div>
                    </div>
                    <p class="review-text">${review.reviewcontent}</p>
                    <span style="font-size: 12px; color: #aaa; margin-top:5px; display:block;">${review.writedate}</span>
                </div>
            </c:forEach>
        </c:if>
        
        <%-- PageBar --%>
        <div class="pagebar" style="margin-top:30px;">
	        <ul class="pagination" style="margin:0; list-style:none; display:flex; justify-content:center; padding:0;">
	            ${requestScope.pageBar}
	        </ul>
	    </div>
        
    </section>

    <jsp:include page="footer1.jsp" />
    
<script>
    const ctxPath = "<%= request.getContextPath() %>";
    let qty = 1;

    const unitPrice = ${pDto.price};
    const unitPoint = ${pDto.point};
    
    const productNo = "${pDto.productno}";
    const isLogin = ${not empty sessionScope.loginuser};
    const loginUrl = "<%= ctxPath%>/login/login.lp";

    function changeQty(num) {
      qty += num;
      if (qty < 1) qty = 1;

      const stock = ${pDto.stock};
      if (qty > stock) {
        alert("죄송합니다. 재고가 " + stock + "개 남았습니다.");
        qty = stock;
      }

      document.getElementById("qty").innerText = qty;

      const total = unitPrice * qty;
      document.getElementById("totalPrice").innerText = "₩ " + total.toLocaleString();
      
      const totalPoint = unitPoint * qty;
      document.getElementById("totalPoint").innerText = totalPoint.toLocaleString();

      const c = document.getElementById("cartQty");
      if (c) c.value = qty;

      const u = document.getElementById("updateQty");
      if (u) u.value = qty;
      
      const b = document.getElementById("buyQty");
      if (b) b.value = qty;
    }

    // 찜하기 (AJAX 비동기 통신)
    function toggleWish() {
      if (!isLogin) {
        alert("로그인이 필요한 서비스입니다.");
        location.href = loginUrl;
        return;
      }
      
      $.ajax({
            url: "<%= ctxPath%>/wishToggle.lp",
            type: "POST",
            data: { "productno": productNo },
            dataType: "json",
            success: function(json) {
                if(json.isSuccess) {
                    const icon = $("#heartIcon");
                    const text = $("#wishText");
                    
                    if(json.result == 1) { // 찜 추가됨
                        icon.removeClass("fa-regular").addClass("fa-solid").css("color", "red");
                        text.text("찜취소");
                    } 
                    else { // 찜 삭제됨
                        icon.removeClass("fa-solid").addClass("fa-regular").css("color", "");
                        text.text("찜하기");
                    }
                } 
                else {
                    if(json.requireLogin) {
                        alert("로그인이 필요합니다.");
                        location.href = loginUrl;
                    } else {
                        alert(json.message);
                    }
                }
            },
            error: function(e) {
                alert("에러 발생: " + e.status);
            }
      });
    }

    
    // 바로 구매하기
    function goOrder() {
	  if (!isLogin) {
	    alert("로그인이 필요한 서비스입니다.");
	    location.href = loginUrl;
	    return;
	  }
	
	  const frm = document.getElementById("buyForm");
	  frm.submit(); 
	}

    function submitCart() {
      const updateForm = document.getElementById("cartUpdateForm");
      const addForm = document.getElementById("cartForm");

      if (updateForm) {
        const choice = confirm("장바구니 수량을 수정하시겠습니까?");
        if (!choice) return;
        updateForm.submit();
        return;
      }

      // 담기 모드
      const choice = confirm("장바구니에 담으시겠습니까?");
      if (!choice) return;

      addForm.method = "post";
      addForm.action = ctxPath + "/order/cartAdd.lp";
      addForm.submit();
    }
</script>

</body>
</html>