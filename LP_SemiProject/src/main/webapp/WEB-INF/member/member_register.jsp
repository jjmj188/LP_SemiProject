<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>회원가입 | LP Shop</title>
  <script type="text/javascript">
      const ctxPath = "<%= request.getContextPath() %>";
  </script>



  <link rel="stylesheet" href="<%= ctxPath %>/css/member/member_register.css">
<link rel="stylesheet" href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">



 
</head>
<body>
<!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<!-- MAIN -->
<main class="login-section">
  <section class="login-container">
    <div class="login-form">
      <h2 class="login-title">회원가입</h2>

      <!-- JS에서 submit 제어 -->
      <form id="registerForm"  name="registerForm" method="post">

        <!-- 성명 -->
        <div class="input-box">
          <label>성명</label>
          <input type="text" name="name" id="name">
        </div>

        <!-- 아이디 -->
        <div class="input-box">
          <label>아이디</label>
          <input type="text" name="userid" id="userid">

          <div class="check-row">
            <button type="button" class="check-btn" id="idcheck">중복확인</button>
            <span id="idCheckResult" class="check-msg"></span>
          </div>
        </div>
 			
 			<!-- 비밀번호 -->
		        <div class="input-box password-box">
		  <label>비밀번호</label>
		  <div class="password-wrap">
		    <input type="password" name="pwd" id="pwd">
		    <span class="pw-toggle" data-target="pwd"></span>
		  </div>
		</div>
		
		<div class="input-box password-box">
		  <label>비밀번호 재확인</label>
		  <div class="password-wrap">
		    <input type="password" id="password_check">
		    <span class="pw-toggle" data-target="password_check"></span>
		  </div>
		</div>

        <!-- 이메일 -->
        <div class="input-box">
          <label>이메일</label>
          <input type="text" name="email" id="email" maxlength="60"
                 placeholder="seoulvinyl@naver.com">

          <!-- 이메일 형식 오류 -->
          <span class="error" id="emailFormatError" style="display:none;">
            이메일 형식에 맞지 않습니다.
          </span>

          <button type="button" class="check-btn" id="emailcheck">
            이메일 중복확인
          </button>

          <span id="emailCheckResult" class="check-msg"></span>
        </div>

        <!-- 연락처 -->
        <div class="input-box">
          <label>연락처</label>
          <input type="text" name="hp1" id="hp1" value="010" readonly>
          <input type="text" name="hp2" id="hp2" maxlength="4">
          <input type="text" name="hp3" id="hp3" maxlength="4">

        </div>
 
        <div class="input-box gender-box">
		  <label class="gender-label">성별</label>
		
		  <div class="gender-row">
		    <label class="gender-option">
		      <input type="radio" name="gender" value="1"> 남
		    </label>
		    <label class="gender-option">
		      <input type="radio" name="gender" value="2"> 여
		    </label>
		  </div>
		</div>

        <!-- 생년월일 -->
        <div class="input-box">
          <label>생년월일</label>
         <input type="text" name="birthday" id="birthday" readonly>
        </div>


		<div class="form-group">
          <label>주소</label>

          <div class="zipcode-row">
           <input type="text" id="postcode" name="postcode"
	       placeholder="우편번호" readonly>

            <button type="button"
                    class="btn-outline"
                    onclick="openDaumPOST()">
              우편번호 찾기
            </button>
          </div>

	        <input type="text" id="address" name="address"
	       class="address-input"
	       placeholder="도로명 주소" readonly>

	         <input type="text" id="detailAddress" name="detailaddress"
	       class="address-input"
	       placeholder="상세 주소">
          
         <input type="text" id="extraAddress" name="extraaddress"
	       class="address-input"
	       placeholder="참고 항목">
        </div>
        <!-- 제출 -->
        <button type="button" class="register-btn" onclick="goRegister()">회원가입</button>

      </form>
    </div>
  </section>
</main>
<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />

<!-- jQuery UI (jQuery 로딩 이후) -->
<script src="https://code.jquery.com/ui/1.13.3/jquery-ui.min.js"></script>

<!-- 다음 주소 API -->
<script src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script src="<%= ctxPath %>/13_daum_address_search/js/daum_address_search.js"></script>

<!-- page JS (맨 마지막) -->
<script src="<%= ctxPath %>/js/member/member_register.js"></script>
</body>
</html>
