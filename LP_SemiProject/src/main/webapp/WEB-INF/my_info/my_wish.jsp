<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>
<%-- [추가] 문자열 처리를 위한 fn 라이브러리 --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">
  <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_wish.css">
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">

  <jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
  <main class="mypage-wrapper">
  <div class="mypage-container">

    <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath%>/my_info/my_info.lp">프로필 수정</a>
      <a href="<%= ctxPath%>/my_info/my_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/my_info/my_wish.lp" class="active">찜내역</a>
      <a href="<%= ctxPath%>/my_info/my_order.lp">구매내역</a>
      <a href="<%= ctxPath%>/my_info/my_taste.lp" >취향선택</a>
    </aside>

    <section class="mypage-content">
      <h2>찜내역</h2>

      
      <div class="wish-list" id="wishContainer">

        <c:if test="${not empty requestScope.wishList}">
            <c:forEach var="item" items="${requestScope.wishList}">
            
                <div class="wish-item" id="item-${item.productno}">
                  
                  <div class="wish-img">
                      <a href="<%= ctxPath%>/productdetail.lp?productno=${item.productno}">
                        
                        <%-- [수정] 이미지 경로 정규화 로직 적용 --%>
                        <c:set var="wishImg" value="${item.productimg}" />
                        <c:if test="${fn:contains(wishImg, 'images')}">
                            <c:set var="wishImg" value="${fn:replace(wishImg, '/images/productimg/', '')}" />
                            <c:set var="wishImg" value="${fn:replace(wishImg, 'images/productimg/', '')}" />
                        </c:if>
                        
                        <%-- 정제된 파일명에 표준 경로 적용 --%>
                        <img src="<%= ctxPath%>/images/productimg/${wishImg}" alt="${item.productname}">
                        
                    </a>
                    
                    <button type="button" class="wish-heart active" onclick="removeWish('${item.productno}')">
                        <i class="fa-solid fa-heart"></i> 
                    </button>
                  </div>
                  
                  <a href="<%= ctxPath%>/productdetail.lp?productno=${item.productno}" class="wish-title-link">
                      <p class="wish-title">${item.productname}</p>
                  </a>

                </div>

            </c:forEach>
        </c:if>
        
        <c:if test="${empty requestScope.wishList}">
            <div class="no-wish">
                <p>찜한 상품이 없습니다.</p>
            </div>
        </c:if>
        
      </div>
      
      <div class="pagebar">
	      <ul class="pagination" style="margin:0; list-style:none; display:flex; justify-content:center; padding:0;">
	          ${requestScope.pageBar}
	      </ul>
	  </div>

    </section>

  </div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
    function goPage(pageNo) {
        sessionStorage.setItem("wishScrollPos", window.scrollY);
        // 페이지 이동
        location.href = "<%= ctxPath%>/my_info/my_wish.lp?currentShowPageNo=" + pageNo;
    }

    $(document).ready(function(){
        const scrollPos = sessionStorage.getItem("wishScrollPos");
        if(scrollPos) {
            window.scrollTo(0, scrollPos); // 스크롤 이동
            sessionStorage.removeItem("wishScrollPos");
        }
    });

    function removeWish(productNo) {
        if( !confirm("정말 삭제하시겠습니까?") ) {
            return; 
        }

        $.ajax({
            url: "<%= ctxPath%>/wishToggle.lp", 
            type: "POST",
            data: { "productno": productNo },
            dataType: "json",
            success: function(json) {
                if(json.isSuccess) {
                    const targetItem = $("#item-" + productNo);
                    targetItem.remove(); 
                    
                    const remainingItems = $("#wishContainer").find(".wish-item").length;

                    if(remainingItems === 0) {
                        location.reload();
                    }
                } 
                else {
                    if(json.requireLogin) {
                        alert("로그인이 필요합니다.");
                        location.href = "<%= ctxPath%>/login/login.lp";
                    } else {
                        alert(json.message);
                    }
                }
            },
            error: function(e) {
                console.log(e);
                alert("삭제 중 오류가 발생했습니다.");
            }
        });
    }
</script>

<style>
    .wish-list {
        min-height: 600px;
        margin-bottom: 20px;
    }

    .wish-title-link {
        text-decoration: none;
        color: inherit;
    }
    .wish-price {
        font-size: 14px;
        color: #666;
        margin-top: 5px;
        font-weight: bold;
    }
    .wish-heart {
        color: red; 
        cursor: pointer;
    }

    /* PAGE BAR 스타일 */
    .pagebar {
      margin-top: 40px;
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 6px;
    }

    .pagebar button {
      min-width: 36px;
      height: 36px;
      padding: 0 10px;
      margin: 0 3px;
      border: 1px solid #ddd;
      background: #fff;
      font-size: 14px;
      color: #222;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .pagebar .page-num {
      font-weight: 500;
    }

    .pagebar .page-num.active {
      background: #222;
      color: #fff;
      border-color: #222;
      cursor: default;
    }

    .pagebar button:not(.active):hover {
      background: #222;
      color: #fff;
      border-color: #222;
    }
</style>