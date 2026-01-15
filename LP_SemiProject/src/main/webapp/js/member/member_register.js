let b_idcheck_click = false;
let b_emailcheck_click = false;

// 유효성 UI 업데이트 함수
function setValidation(selector, isValid, msg = "", isSuccess = false) {
    const $el = $(selector);
    const $error = $(selector + "_error");
    
    if (!isValid) {
        $el.addClass("input-error");
        if($error.length) $error.text(msg).css("color", "red").show();
    } else {
        $el.removeClass("input-error");
        if($error.length) {
            if(isSuccess) $error.text(msg).css("color", "green").show();
            else $error.hide();
        }
    }
}

// 주소 API (바깥으로 빼두는 것이 안전합니다)
function openDaumPOST() {
    new daum.Postcode({
        oncomplete: function(data) {
            let addr = data.userSelectedType === 'R' ? data.roadAddress : data.jibunAddress;
            $("#postcode").val(data.zonecode);
            $("#address").val(addr);
            $("#postcode, #address").removeClass("input-error");
            $("#address_error").hide();
            $("#detailAddress").focus();
        }
    }).open();
}

$(function(){
	$(".pw-toggle").on("click", function() {
	        const targetId = $(this).attr("data-target");
	        const $pwdInput = $("#" + targetId);

	        if ($pwdInput.attr("type") === "password") {
	            $pwdInput.attr("type", "text");
	            $(this).removeClass("fa-eye-slash").addClass("fa-eye");
	        } else {
	            $pwdInput.attr("type", "password");
	            $(this).removeClass("fa-eye").addClass("fa-eye-slash");
	        }
	    });
    /* ======================================================
       2. 각 필드 Blur 시 유효성 검사
    ====================================================== */
    $("#name").on("blur", function() {
        const reg = /^([가-힣]{2,10}|[a-zA-Z]{2,20})$/;
        if($(this).val().trim() === "") setValidation("#name", false, "이름을 입력해 주세요.");
        else if(!reg.test($(this).val().trim())) setValidation("#name", false, "한글 2~10자 또는 영문 2~20자 이내로 작성해 주세요.");
        else setValidation("#name", true);
    });

    $("#userid").on("blur", function() {
        const val = $(this).val().trim();
        const reg = /^(?=.*[a-z])(?=.*\d)[a-z\d]{8,15}$/;
        if(val === "") setValidation("#userid", false, "아이디를 입력해 주세요.");
        else if(!reg.test(val)) setValidation("#userid", false, "특수문자 및 대문자를 제외한 8~15자의 영문 소문자, 숫자를 조합해 주세요.");
        else if(!b_idcheck_click) setValidation("#userid", true, "중복 확인을 진행해 주세요.");
    });

    $("#pwd").on("blur", function() {
        const reg = /^(?=.*[a-zA-Z])(?=.*\d)(?=.*[^a-zA-Z0-9]).{8,15}$/;
        if($(this).val() === "") setValidation("#pwd", false, "비밀번호를 입력해 주세요.");
        else if(!reg.test($(this).val())) setValidation("#pwd", false, "8~15자의 영문 대/소문자, 숫자, 특수문자를 조합해 주세요.");
        else setValidation("#pwd", true);
    });

    $("#password_check").on("blur", function() {
        const pwd = $("#pwd").val();
        const pwdCheck = $(this).val();
        if(pwdCheck === "") setValidation("#password_check", false, "비밀번호를 한 번 더 입력해 주세요.");
        else if(pwd !== pwdCheck) setValidation("#password_check", false, "비밀번호가 일치하지 않습니다.");
        else setValidation("#password_check", true);
    });

    $("#email").on("blur", function() {
        const reg =/^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@naver\.com$/i;
        const val = $(this).val().trim();
        if(val === "") setValidation("#email", false, "이메일 주소를 입력해 주세요.");
        else if(!reg.test(val)) setValidation("#email", false, "올바른 이메일 형식을 입력해 주세요.(네이버 메일만 가능)");
        else if(!b_emailcheck_click) setValidation("#email", true, "이메일 중복 확인을 진행해 주세요.");
    });

    /* ======================================================
       3. 중복확인 버튼 클릭 이벤트
    ====================================================== */
    $("#idcheck").click(function(){
        const userid = $("#userid").val().trim();
		if(userid === "") {
		        setValidation("#userid", false, "아이디를 입력해 주세요.");
		        return;
		    }

		    // 2순위: 정규식 체크 (대문자 제외, 소문자+숫자 조합 8~15자)
		    const idreg = /^(?=.*[a-z])(?=.*\d)[a-z\d]{8,15}$/;
		    if(!idreg.test(userid)) {
		        setValidation("#userid", false, "특수문자 및 대문자를 제외한 8~15자의 영문 소문자, 숫자를 조합해 주세요.");
		        return;
		    }
        $.ajax({
            url: ctxPath + "/member/idDuplicateCheck.lp",
            type: "post", data: { userid }, dataType: "json",
            success: function(json) {
                if(json.isExists) {
                    b_idcheck_click = false;
                    setValidation("#userid", false, "이미 사용 중인 아이디입니다.다른 아이디를 입력해 주세요.");
                } else {
                    b_idcheck_click = true;
                    setValidation("#userid", true, "사용 가능한 아이디입니다.", true);
					
				}
            }
        });
    });
	
	//중복확인 후 아이디 input값이 변했을 경우 
	$("#userid").on("input", function() {
	    b_idcheck_click = false; 
	});
	
	//이메일 중복 확인 
    $("#emailcheck").click(function(){
		const reg =/^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@naver\.com$/i;
        const email = $("#email").val().trim();
        if(email === "") { 
			setValidation("#email", false, "이메일을 입력해 주세요."); 
			return;
		 }else if(!reg.test(email)){
			setValidation("#email", false, "올바른 이메일 형식을 입력해 주세요.(네이버 메일만 가능)");
					        return;
		 }
		 
		 
        $.ajax({
            url: ctxPath + "/member/emailDuplicateCheck.lp",
            type: "post", data: { email }, dataType: "json",
            success: function(json) {
                if(json.isExists) {
                    b_emailcheck_click = false;
                    setValidation("#email", false, "이미 사용 중인 이메일입니다.다른 이메일을 입력해 주세요.");
                } else {
                    b_emailcheck_click = true;
                    setValidation("#email", true, "사용 가능한 이메일입니다.", true);
					
                }
            }
        });
    });
	//중복확인 후 이메일 input값이 변했을 경우 
		$("#email").on("input", function() {
		    b_emailcheck_click = false; 
		});
    /* ======================================================
       4. 기타 필드 (연락처, 생년월일, 성별)
    ====================================================== */
    $("#hp2, #hp3").on("blur", function() {
        const hp2 = $("#hp2").val();
        const hp3 = $("#hp3").val();
        if(!/^\d{4}$/.test(hp2) || !/^\d{4}$/.test(hp3)) {
            $("#hp2, #hp3").addClass("input-error");
            $("#hp_error").text("연락처는 각각 4자리의 숫자로 입력해 주세요.").css("color", "red").show();
        } else {
            $("#hp2, #hp3").removeClass("input-error");
            $("#hp_error").hide();
        }
    });

	/* ======================================================
	       4. 생년월일 (오늘 이후 날짜 선택 불가)
	    ====================================================== */
	    $("#birthday").datepicker({
	        dateFormat: "yy-mm-dd",
	        changeYear: true,
	        yearRange: "1900:+0",
	        maxDate: 0, //  오늘 이후 날짜는 비활성화 (고쳐진 부분)
	        onSelect: function() {
	            $("#birthday").removeClass("input-error");
	            $("#birthday_error").hide();
	        }
	    });

	// --- [수정] 성별 선택 시 로직 ---
	$("input[name='gender']").on("change", function() {
	    // 성별을 고르는 순간 에러 메시지만 딱 숨깁니다.
	    $("#gender_error").hide();
	});
    $("#detailAddress").on("blur", function() {
        if($(this).val().trim() !== "") {
            $(this).removeClass("input-error");
            $("#address_error").hide();
        }
    });
});

/* ======================================================
   5. 최종 가입 버튼 함수
====================================================== */
function goRegister() {
    $("input").trigger("blur");

    let canSubmit = true;
    if(!b_idcheck_click) { setValidation("#userid", false, "아이디 중복 확인이 필요합니다."); canSubmit = false; }
    if(!b_emailcheck_click) { setValidation("#email", false, "이메일 중복 확인이 필요합니다."); canSubmit = false; }
    
	// --- [수정] 성별 체크 부분 ---
	    if($("input[name='gender']:checked").length === 0) {
	        // 라벨 색상은 건드리지 않고, 에러 메시지만 보여줍니다.
	        $("#gender_error").text("성별을 선택해 주세요.").show();
	        canSubmit = false;
	    }
		
		// --- 생년월일 체크 ---
		if($("#birthday").val() === "") {
		    $("#birthday").addClass("input-error");
		    $("#birthday_error").text("생년월일을 입력해 주세요.").show(); // 메시지 추가
		    canSubmit = false;
		} else {
		    $("#birthday").removeClass("input-error");
		    $("#birthday_error").hide();
		}
		/* ======================================================
		       [수정 핵심] 주소/상세주소 체크
		    ====================================================== */
		    const postcode = $("#postcode").val().trim();
		    const address = $("#address").val().trim();
		    const detailAddress = $("#detailAddress").val().trim(); // HTML ID와 대소문자 일치시킴

		    if(postcode === "" || address === "" || detailAddress === "") {
		        // 빈 항목에 빨간 테두리 추가
		        if(postcode === "") $("#postcode").addClass("input-error");
		        if(address === "") $("#address").addClass("input-error");
		        if(detailAddress === "") $("#detailAddress").addClass("input-error");

		        // 구체적인 에러 메시지 출력
		        if(postcode === "" || address === "") {
		            $("#address_error").text("우편번호 찾기를 진행해 주세요.").css("color", "red").show();
		        } else {
		            $("#address_error").text("상세 주소를 입력해 주세요.").css("color", "red").show();
		        }
		        canSubmit = false;
		    } else {
		        $("#postcode, #address, #detailAddress").removeClass("input-error");
		        $("#address_error").hide();
		    }

    if($(".input-error").length > 0) canSubmit = false;

    if(canSubmit) {
        $("#registerForm").attr("action", ctxPath + "/member/member_register.lp").submit();
    } else {
        const $firstError = $(".input-error").first();
        if($firstError.length) {
            $('html, body').animate({ scrollTop: $firstError.offset().top - 100 }, 300);
            $firstError.focus();
        }
    }
}