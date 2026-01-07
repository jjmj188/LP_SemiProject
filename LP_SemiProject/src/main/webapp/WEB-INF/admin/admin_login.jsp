<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
    // /LP_SemiProject
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 로그인</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_login.css">

<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>

<script type="text/javascript">
    
    // 페이지 로딩 후 실행
    document.addEventListener("DOMContentLoaded", function(){
        
        // 아이디 입력창에 포커스
        const adminIdInput = document.getElementById("adminid");
        adminIdInput.focus();

        // 엔터키 입력 시 로그인 시도
        const adminPwdInput = document.getElementById("adminpwd");
        adminPwdInput.addEventListener("keydown", function(e){
            if(e.keyCode == 13) { // 13 is Enter
                goLogin();
            }
        });
        
        // 아이디 저장 기능 (로컬 스토리지 사용 예시)
        const savedId = localStorage.getItem("saveAdminId");
        if(savedId) {
            adminIdInput.value = savedId;
            document.getElementById("saveIdCheckbox").checked = true;
        }
    });

    // 로그인 실행 함수
    function goLogin() {
        const adminid = document.getElementById("adminid");
        const adminpwd = document.getElementById("adminpwd");
        const saveIdCheck = document.getElementById("saveIdCheckbox");

        if(adminid.value.trim() == "") {
            alert("아이디를 입력해주세요.");
            adminid.focus();
            return;
        }

        if(adminpwd.value.trim() == "") {
            alert("비밀번호를 입력해주세요.");
            adminpwd.focus();
            return;
        }
        
        // 아이디 저장 체크 여부 확인
        if(saveIdCheck.checked) {
            localStorage.setItem("saveAdminId", adminid.value);
        } else {
            localStorage.removeItem("saveAdminId");
        }

        // 폼 전송
        const frm = document.loginFrm;
        frm.action = "<%= ctxPath%>/admin/admin_login.lp"; // Controller 매핑 주소
        frm.method = "POST";
        frm.submit();
    }

</script>
</head>
<body>
  
  <main class="login-wrapper">

    <section class="login-container">

      <div class="login-box">

        <div class="login-tab">
          <span class="tab-item active" data-type="user">관리자 로그인</span>
        </div>

        <form name="loginFrm">
            
            <div class="input-group">
              <label for="adminid">아이디</label>
              <input type="text" placeholder="아이디 입력" id="adminid" name="adminid">
            </div>
      
            <div class="input-group">
              <label for="adminpwd">비밀번호</label>
              <input type="password" placeholder="비밀번호 입력" id="adminpwd" name="adminpwd">
            </div>
      
            <div class="login-options">
              <label>
                <input type="checkbox" id="saveIdCheckbox">
                아이디 저장
              </label>
            </div>
      
            <button type="button" class="btn-login" onclick="goLogin()">
              로그인
            </button>
            
        </form>
        </div>
    </section>

  </main>

  <jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>