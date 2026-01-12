<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>마이페이지 | 내정보 수정</title>
<script>
  const ctxPath = "<%= ctxPath %>";
</script>
<!-- 다음 주소 API -->
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script> 
<script src="<%= ctxPath %>/13_daum_address_search/js/daum_address_search.js"></script>
<script src="<%= ctxPath %>/js/my_info/my_edit.js"></script>




<link rel="stylesheet" href="<%=ctxPath%>/css/my_info/my_info.css">



<link rel="stylesheet" href="<%=ctxPath%>/css/my_info/my_info.css">


 <link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">
 <link rel="stylesheet" href="<%=ctxPath%>/css/my_info/my_info.css">
</head>
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
<body>

<main class="mypage-wrapper">
  <div class="mypage-container">

    <!-- 왼쪽 메뉴 -->
       <aside class="mypage-menu">
      <h3>마이페이지</h3>  
      <a href="<%= ctxPath%>/my_info/my_info.lp"  class="active">프로필 수정</a>
      <a href="<%= ctxPath%>/my_info/my_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/my_info/my_wish.lp" >찜내역</a>
      <a href="<%= ctxPath%>/my_info/my_order.lp">구매내역</a>
      <a href="<%= ctxPath%>/my_info/my_taste.lp" >취향선택</a>
    </aside>

    <!-- 가운데 요약 -->
    <section class="mypage-info">

      <div class="info-box">
        <h4>보유 포인트</h4>
        <div class="point">
          ${sessionScope.loginuser.point} P
        </div>
      </div>

      <div class="info-box">
        <h4>내가 쓴 리뷰</h4>
   
         <iframe
	  src="<%=ctxPath%>/my_info/my_review_iframe.lp"
	  width="100%"
	  height="350"
	  frameborder="0"
	  scrolling="auto">
	</iframe> 

      </div>
    </section>

    <!-- 오른쪽 콘텐츠 -->
    <section class="mypage-content">

      <h2>프로필 수정</h2>

      <form name="editFrm">

        <input type="hidden" name="userid"
               value="${sessionScope.loginuser.userid}">

        <div class="form-group">
          <label>성명 *</label>
         <input type="text" name="name" id="name"
       value="${sessionScope.loginuser.name}">

        </div>

        <div class="form-group">
		  <label>이메일 *</label>
		  <div class="email-row">
		    <input type="text" name="email" id="email" value="${sessionScope.loginuser.email}">
		    <button type="button" id="btnEmailCheck">중복확인</button>
		    
		    <span id="emailCheckResult"></span>
		  </div>
		</div>

           <div class="form-group">
		  <label>휴대폰</label>
		  <div class="hp-row">
		    <input type="text" value="010" readonly>
		    <span class="hyphen">-</span> <input type="text" name="hp2" id="hp2" maxlength="4"
		           value="${fn:substring(sessionScope.loginuser.mobile,3,7)}">
		    <span class="hyphen">-</span> <input type="text" name="hp3" id="hp3" maxlength="4"
		           value="${fn:substring(sessionScope.loginuser.mobile,7,11)}">
		  </div>
		</div>

        <div class="form-group">
          <label>주소</label>

          <div class="zipcode-row">
           <input type="text" id="postcode" name="postcode"
	       placeholder="우편번호" readonly
	       value="${sessionScope.loginuser.postcode}">

            <button type="button"
                    class="btn-outline"
                    onclick="openDaumPOST()">
              우편번호 찾기
            </button>
          </div>

	        <input type="text" id="address" name="address"
	       class="address-input"
	       placeholder="도로명 주소" readonly
	       value="${sessionScope.loginuser.address}">

	         <input type="text" id="detailAddress" name="detailaddress"
	       class="address-input"
	       placeholder="상세 주소"
	       value="${sessionScope.loginuser.detailaddress}">
          
         <input type="text" id="extraAddress" name="extraaddress"
	       class="address-input"
	       placeholder="참고 항목"
	       value="${sessionScope.loginuser.extraaddress}">
        </div>

        <!--  버튼 영역 -->
        <div class="button-area">

          <!-- 회원탈퇴 -->
          <button type="button"
                  class="btn-delete"
                  onclick="location.href='<%=ctxPath%>/member/member_withdraw.lp'">
            회원탈퇴
          </button>

          <!-- 비밀번호 변경 -->
          <button type="button"
                  class="btn-outline"
                  onclick="location.href='<%=ctxPath%>/login/pwd_change.lp'">
            비밀번호 변경하기
          </button>

          <!-- 저장 -->
          <button type="button"
                  class="btn-dark"
                  onclick="goEdit()">
            저장하기
          </button>

        </div>

      </form>

    </section>

  </div>
</main>

<div id="reviewModal" style="display:none; position:fixed; top:0; left:0; width:100%; height:100%; background:rgba(0,0,0,0.5); z-index:9999; justify-content:center; align-items:center;">
    <div style="background:#fff; width:550px; height:550px; border-radius:15px; position:relative; overflow:hidden; box-shadow: 0 5px 15px rgba(0,0,0,0.3);">
        
        <iframe id="modalIframe" src="" width="100%" height="100%" frameborder="0"></iframe>
        
        <button onclick="closeReviewModal()" style="position:absolute; top:15px; right:15px; background:none; border:none; font-size:24px; cursor:pointer; color:#333;">&times;</button>
    </div>
</div>
<script>
//모달 열기 함수 (자식 iframe에서 호출할 것임)
function openReviewModal(reviewno) {
    const modal = document.getElementById("reviewModal");
    const modalIframe = document.getElementById("modalIframe");

    // 1. 상세페이지 주소 설정 (컨트롤러 주소 + 리뷰번호)
    modalIframe.src = "<%= request.getContextPath() %>/my_info/my_review_iframe.lp?reviewno=" + reviewno;

    // 2. 모달 보이기
    modal.style.display = "flex";
}

// 모달 닫기 함수
function closeReviewModal() {
    const modal = document.getElementById("reviewModal");
    const modalIframe = document.getElementById("modalIframe");

    modal.style.display = "none";
    modalIframe.src = ""; // 닫을 때 주소를 비워줘야 다음에 깔끔하게 뜹니다.
}</script>

<!--  daum_address_search.js 에러방지용-->
<div style="display: none;">
    <input type="checkbox" id="allCheck">
    <input type="checkbox" name="product_old">
    <input type="checkbox" name="product_usa">
</div>

<jsp:include page="/WEB-INF/footer1.jsp" />
</body>
</html>
