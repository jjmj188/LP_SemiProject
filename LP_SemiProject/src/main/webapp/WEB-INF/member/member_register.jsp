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

  <!-- jQuery -->
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<!-- jQuery UI CSS -->
<link rel="stylesheet"
      href="https://code.jquery.com/ui/1.13.3/themes/base/jquery-ui.css">
<link rel="stylesheet" href="<%= ctxPath %>/css/member/member_register.css">

<!-- jQuery UI JS -->
<script src="https://code.jquery.com/ui/1.13.3/jquery-ui.min.js"></script>

  <!-- 회원가입 JS -->
 <script type="text/javascript">
    const ctxPath = "<%= request.getContextPath() %>";
</script>
  <script type="text/javascript" src="<%= ctxPath %>/js/member/member_register.js"></script>
</head>

<body>

<!-- HEADER -->
<div id="header"></div>

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
          <button type="button" class="check-btn" id="idcheck">중복확인</button>
          <div id="idCheckResult" class="check-msg"></div>
        </div>
 			
 			<!-- 비밀번호 -->
		        <div class="input-box password-box">
		  <label>비밀번호</label>
		  <div class="password-wrap">
		    <input type="password" name="pwd" id="pwd">
		    <span class="toggle-eye" data-target="pwd"></span>
		  </div>
		</div>
		
		<div class="input-box password-box">
		  <label>비밀번호 재확인</label>
		  <div class="password-wrap">
		    <input type="password" id="password_check">
		    <span class="toggle-eye" data-target="password_check"></span>
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

        <!-- 성별 -->
        <div class="input-box">
          <label>성별</label>
          <label>
            <input type="radio" name="gender" value="1"> 남
          </label>
          <label>
            <input type="radio" name="gender" value="2"> 여
          </label>
        </div>

        <!-- 생년월일 -->
        <div class="input-box">
          <label>생년월일</label>
         <input type="text" name="birthday" id="birthday" readonly>
        </div>

        <!-- 제출 -->
        <button type="button" class="register-btn" onclick="goRegister()">회원가입</button>

      </form>
    </div>
  </section>
</main>

<!-- FOOTER -->
<div id="footer"></div>

</body>
</html>
