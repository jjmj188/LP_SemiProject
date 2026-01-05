let b_idcheck_click = false;
let b_emailcheck_click = false;

$(function(){
	
    /* =========================
       아이디 중복확인 
    ========================= */
    $("#idcheck").click(function(){
        const userid = $("#userid").val().trim();
        const regUserid = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{8,15}$/;

        if(userid === ""){
            alert("아이디를 입력하세요.");
            $("#userid").focus();
            return;
        }

        if(!regUserid.test(userid)){
            alert("아이디는 8~15자의 영문자와 숫자를 포함해야 합니다.");
            $("#userid").focus();
            return;
        }
        
        $.ajax({
            url: ctxPath + "/member/idDuplicateCheck.lp",
            type: "post",
            data: { userid },
            dataType: "json",
            success:function(json){
                if(json.isExists){
                    $("#idCheckResult").text("이미 사용중인 아이디입니다.").css("color","red");
                    $("#userid").val("").focus();
                    b_idcheck_click = false;
                } else {
                    $("#idCheckResult").text("사용 가능한 아이디입니다.").css("color","green");
                    b_idcheck_click = true;
                }
            }
        });
    });
	/* ================================
	   아이디 중복확인 후 수정했을 경우 중복 재확인 
	    ================================*/
	$("#userid").on("input", function () {
	    b_idcheck_click = false;
	    $("#idCheckResult")
	        .text("아이디 중복확인을 해주세요.")
	        .css("color", "red");
	});

    /* =========================
       이메일 중복확인 
    ========================= */
    $("#emailcheck").click(function(){
        const email = $("#email").val().trim();
        const regEmail =  /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i; 

        if(email === ""){
            alert("이메일을 입력하세요.");
            $("#email").focus();
            return;
        }

        if(!regEmail.test(email)){
            alert("이메일 형식이 올바르지 않습니다.");
            $("#email").focus();
            return;
        }

        $.ajax({
            url: ctxPath + "/member/emailDuplicateCheck.lp", 
            type: "post",
            data: { email },
            dataType: "json",
            success:function(json){
                if(json.isExists){
                    $("#emailCheckResult").text("이미 사용중인 이메일입니다.").css("color","red");
                    $("#email").val("").focus();
                    b_emailcheck_click = false;
                } else {
                    $("#emailCheckResult").text("사용 가능한 이메일입니다.").css("color","green");
                    b_emailcheck_click = true;
                }
            }
        });
    });
	/* ================================
	   이메일 중복확인 후 수정했을 경우 중복 재확인 
	   ================================*/
	
	$("#email").on("input", function () {
	    b_emailcheck_click = false;
	    $("#emailCheckResult")
	        .text("이메일 중복확인을 해주세요.")
	        .css("color", "red");
	});
	//7.핸드폰 
		$("#hp2, #hp3").on("input", function () {
		    this.value = this.value.replace(/[^0-9]/g, "");
		});
		/* =========================
		   datepicker 설정 수정
		========================= */
		$("#birthday").datepicker({
		    dateFormat: "yy-mm-dd",
		    changeYear: true,
		    changeMonth: true,
		    yearRange: "1900:+0",
		    maxDate: 0  // 0은 오늘을 의미하며, 오늘 이후 날짜는 선택 불가(회색 처리)
		});
		/* =========================
		   주소 유효성 검사
		========================= */
	
	
	
});
function validateAddress() {

		    const postcode = $("#postcode").val().trim();
		    const address  = $("#address").val().trim();
		    const detail   = $("#detailAddress").val().trim();

		    // 1️ 우편번호
		    if (postcode === "") {
		        alert("우편번호를 입력하세요.");
		        $("#postcode").focus();
		        return false;
		    }

		    // 2️ 도로명 주소
		    if (address === "") {
		        alert("도로명 주소를 입력하세요.");
		        $("#address").focus();
		        return false;
		    }

		    // 3️ 상세 주소
		    if (detail === "") {
		        alert("상세 주소를 입력하세요.");
		        $("#detailAddress").focus();
		        return false;
		    }

		    return true;
		}
/* ======================================================
   회원가입 전송 함수 (goRegister)
   이 함수가 실행될 때 최종적으로 POST로 전송
====================================================== */
function goRegister() {
	const regName = /^([가-힣]{2,10}|[a-zA-Z]{2,20})$/;
    // 1. 성명 검사
	const name = $("#name").val().trim();
	
	if($("#name").val().trim() === ""){
        alert("성명을 입력하세요.");
        $("#name").focus();
        return;
    }
	

	if (!regName.test(name)) {
	    alert("성명은 한글 2~10자 또는 영문 2~20자만 가능합니다.");
	    $("#name").focus();
	    return;
	}
	
    // 2. 아이디 중복확인 검사
	const userid = $("#userid").val().trim();

	if (userid === "") {
	    alert("아이디를 입력하세요.");
	    $("#userid").focus();
	    return;
	}

	const regUserid = /^(?=.*[a-zA-Z])(?=.*\d)[a-zA-Z\d]{8,15}$/;

	if (!regUserid.test(userid)) {
	    alert("아이디는 8~15자의 영문자와 숫자를 반드시 포함해야 합니다.");
	    $("#userid").focus();
	    return;
	}
	
	if (!b_idcheck_click) {
	    alert("아이디 중복확인을 해주세요.");
	    return;
	}
    // 3. 비밀번호 유효성 및 일치 검사
    const pwd = $("#pwd").val();
    const regPwd = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,15}$/;

    if(!regPwd.test(pwd)){
        alert("비밀번호는 8~15자의 영문자, 숫자, 특수문자를 포함해야 합니다.");
        $("#pwd").focus();
        return;
    }

    if(pwd !== $("#password_check").val()){
        alert("비밀번호가 일치하지 않습니다.");
        $("#password_check").focus();
        return;
    }

    // 4. 이메일 중복확인 검사
    if(!b_emailcheck_click){
        alert("이메일 중복확인을 해주세요.");
        return;
    }

    // 5. 성별 선택 검사
    if($("input[name='gender']:checked").length === 0){
        alert("성별을 선택하세요.");
        return;
    }

	// 6. 휴대폰 검사 & 조합
		const hp1 = $("#hp1").val(); // "010"
		const hp2 = $("#hp2").val().trim();
		const hp3 = $("#hp3").val().trim();

		if (!/^\d{4}$/.test(hp2) || !/^\d{4}$/.test(hp3)) {
		    alert("연락처는 숫자 4자리씩 입력하세요.");
		    $("#hp2").focus();
		    return;
		}

		// hidden mobile 세팅
		$("#mobile").val(hp1 + hp2 + hp3);
	
    // 7. 생년월일 검사
    if($("#birthday").val().trim() === ""){
        alert("생년월일을 선택하세요.");
        return;
    }
	
	
	// 8. 주소 유효성 검사
	if (!validateAddress()) {
	    return;
	}
	// 8. 최종 전송 (POST)
	const frm = document.getElementById("registerForm");
	frm.method = "post";
	frm.action = "member_register.lp";
	frm.submit();
}


$(".pw-toggle").on("click", function () {
    const target = $("#" + $(this).data("target"));

    if (target.attr("type") === "password") {
        target.attr("type", "text");
        $(this).text("숨김");
    } else {
        target.attr("type", "password");
        $(this).text("보기");
    }
});