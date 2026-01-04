
$(function(){
	
	$('button#btnSubmit').click(e=>{
	goLogin_Cookies();     
	
	});
	
 
	$('input#loginPwd').keydown(e=>{
		if(e.keyCode == 13) { // 암호입력란에 엔터를 했을 경우 
		goLogin_Cookies();     
	      
		}
	});
	
});// end of $(function(){})---------------------------


// Function Declaration

// === 로그인 처리 함수(Cookie 사용 버전) ===
function goLogin_Cookies(){
	
	const userid = $('input#loginUserid').val().trim();
	const pwd = $('input#loginPwd').val().trim();

	if(userid == "") {
		alert("아이디를 입력하세요!!");
		$('input#loginUserid').val("").focus();
		return;
	}
	
	if(pwd == "") {
		alert("암호를 입력하세요!!");
		$('input#loginPwd').val("").focus();
		return;
	}
	
	// 폼 전송
	const frm = document.loginFrm;
	frm.action = "login.lp"; // 경로가 확실치 않으면 명시적으로 지정
	frm.submit();
}






















