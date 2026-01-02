<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>

 <!-- 로그인 전용 -->
  <link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_login.css">
  
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
  
  <!-- MAIN -->
<main class="login-wrapper">

  <!-- 🔥 mypage 기준 container -->
  <section class="login-container">

    <!-- 로그인 박스 -->
    <div class="login-box">

      <!-- 로그인 탭 -->
      <div class="login-tab">
        <span class="tab-item active" data-type="user">관리자 로그인</span>
      
      </div>

      <!-- 아이디 -->
      <div class="input-group">
        <label>아이디</label>
        <input type="text" placeholder="아이디 입력" id="loginId">
      </div>

      <!-- 비밀번호 -->
      <div class="input-group">
        <label>비밀번호</label>
        <input type="password" placeholder="비밀번호 입력">
      </div>

      <!-- 옵션 -->
      <div class="login-options">
        <label>
          <input type="checkbox">
          아이디 저장
        </label>

     
      </div>

      <!-- 버튼 -->
      <button class="btn-login" onclick="location.href='#'">
        로그인
      </button>

    </div>
  </section>

</main>

<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
