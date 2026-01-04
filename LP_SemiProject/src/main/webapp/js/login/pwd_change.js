$(function () {

  $("#btnPwdChange").click(function () {

    const newPwd = $("#newPwd").val().trim();
    const newPwdCheck = $("#newPwdCheck").val().trim();
	const regPwd = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,15}$/;

    // 1️ 새 비밀번호 입력 여부
    if (newPwd === "") {
      alert("새 비밀번호를 입력하세요.");
      $("#newPwd").focus();
      return;
    }
	
	//비밀번호 유효성검사
	if(!regPwd.test(newPwd)){
	        alert("비밀번호는 8~15자의 영문자, 숫자, 특수문자를 포함해야 합니다.");
	        $("#newPwd").focus();
	        return;
	    }
    // 2️ 비밀번호 확인 입력 여부
    if (newPwdCheck === "") {
      alert("비밀번호 확인을 입력하세요.");
      $("#newPwdCheck").focus();
      return;
    }

    // 3️ 비밀번호 일치 검사
    if (newPwd !== newPwdCheck) {
      alert("비밀번호가 일치하지 않습니다.");
      $("#newPwdCheck").val("").focus();
      return;
    }

    // 4️ 전부 통과 → 서버로 전송
    document.pwdChangeFrm.submit();

  });

});
