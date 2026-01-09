<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<%
    String ctxPath = request.getContextPath();
    // /LP_SemiProject
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
                        <img src="<%= ctxPath%>${item.productimg}" alt="${item.productname}">
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
                <i class="fa-regular fa-face-sad-tear"></i>
                <p>찜한 상품이 없습니다.</p>
            </div>
        </c:if>
        
      </div>

       </section>

  </div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
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
                    // 3. 성공 시 화면에서 해당 박스(div) 즉시 제거
                    const targetItem = $("#item-" + productNo);
                    targetItem.remove(); 
                    
                    // 4. 남은 개수 확인하기
                    // #wishContainer 안에 .wish-item 클래스를 가진 요소가 몇 개인지 셉니다.
                    const remainingItems = $("#wishContainer").find(".wish-item").length;

                    // 5. 하나도 없으면 "찜한 상품이 없습니다" 메시지 띄우기
                    if(remainingItems === 0) {
                        const emptyHtml = `
                            <div class="no-wish">
                                <i class="fa-regular fa-face-sad-tear"></i>
                                <p>찜한 상품이 없습니다.</p>
                            </div>
                        `;
                        $("#wishContainer").html(emptyHtml);
                    }
                } 
                else {
                    // 로그인 풀림 등 에러 처리
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
    /* 하트 버튼 위치 조정 (필요시) */
    .wish-heart {
        color: red; /* 항상 빨간색 */
        cursor: pointer;
    }
</style>