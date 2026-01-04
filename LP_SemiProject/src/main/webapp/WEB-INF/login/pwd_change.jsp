<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String ctx_Path = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>비밀번호 재설정</title>



<!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
<!-- CSS -->
<link rel="stylesheet" href="<%= ctx_Path %>/css/login/pwd_change.css">

<!-- JS -->
<script src="<%= ctx_Path %>/js/login/pwd_change.js"></script>

</head>
<body>

<div class="pwd-wrapper">

    <h2>비밀번호 재설정</h2>

    <p class="notice">
        보안을 위해 비밀번호를 다시 설정해주세요.
    </p>

    <form name="pwdChangeFrm"
          action="<%= ctx_Path %>/login/pwd_change.lp"
          method="post">

        <!-- 새 비밀번호 -->
        <div class="input-box">
            <label for="newPwd">새 비밀번호</label>
            <input type="password"
                   id="newPwd"
                   name="newPwd"
                   placeholder="새 비밀번호 입력">
        </div>

        <!-- 새 비밀번호 확인 -->
        <div class="input-box">
            <label for="newPwdCheck">비밀번호 확인</label>
            <input type="password"
                   id="newPwdCheck"
                   name="newPwdCheck"
                   placeholder="비밀번호 다시 입력">
        </div>

        <!-- 버튼 -->
        <div class="btn-area">
            <button type="button" id="btnPwdChange">
                비밀번호 변경
            </button>
        </div>

    </form>

</div>
<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
</body>
</html>
