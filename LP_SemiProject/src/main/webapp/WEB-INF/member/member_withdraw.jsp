<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>회원 탈퇴</title>

<!-- jQuery (AJAX 필수) -->
<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>

<!-- 마이페이지 공통 레이아웃 <link rel="stylesheet" href="<%=ctxPath%>/css/my_info/mypage_layout.css">-->


<!-- 회원탈퇴 전용 CSS -->
<link rel="stylesheet" href="<%=ctxPath%>/css/member/member_withdraw.css">

<script>
function goWithdraw() {
    const pwd = document.getElementById("pwd").value;
    const pwdError = document.getElementById("pwdError");

    if (pwd.trim() === "") {
        alert("비밀번호를 입력하세요.");
        return;
    }

    // 🔹 Step 1: 비밀번호 AJAX 검증
    $.ajax({
        url: "<%= ctxPath %>/member/check_pwdJson.lp",
        type: "post",
        data: { pwd: pwd },
        dataType: "json",
        success: function (json) {
            if (json.isMatch) {
                pwdError.style.display = "none";

                if (confirm("탈퇴된 계정은 복구할 수 없습니다.\n정말로 탈퇴하시겠습니까?")) {
                    // 🔹 Step 2: 실제 탈퇴 처리
                    document.withdrawFrm.submit();
                }
            } else {
                pwdError.style.display = "block";
                $("#pwd").val("").focus();
            }
        },
        error: function () {
            alert("서버 통신 중 오류가 발생했습니다.");
        }
    });
}
</script>
</head>

<body>

<!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp" />

<main class="mypage-wrapper">
  <div class="mypage-container">
<main>
  <div class="pwd-wrapper withdraw-wrapper">

    <h2>회원 탈퇴</h2>

    <div class="warning-notice">
      <p>⚠️ <strong>탈퇴 전 꼭 확인해주세요</strong></p>
      <p>
        탈퇴 시 계정 복구가 불가능하며<br>
        포인트 및 모든 혜택이 소멸됩니다.
      </p>
    </div>

    <form name="withdrawFrm"
          method="post"
          action="<%=ctxPath%>/member/member_withdraw.lp">

      <div class="input-box">
        <label>비밀번호 확인</label>
        <input type="password" name="pwd" id="pwd">

        <div id="pwdError" class="pwd-error">
          비밀번호가 일치하지 않습니다.
        </div>
      </div>

      <div class="btn-group">
        <button type="button" id="btnWithdraw" onclick="goWithdraw()">
          탈퇴하기
        </button>
        <button type="button" id="btnCancel" onclick="history.back()">
          취소
        </button>
      </div>

    </form>

  </div>
</main>

</body>
</html>
