//  이메일 중복확인 여부
let b_emailcheck_click = true; // 처음엔 true (기존 이메일 유지 가능)
let originalEmail = "";       

$(function(){

    /* =========================
       초기 세팅
    ========================= */
    originalEmail = $("#email").val().trim();

    /* =========================
       이메일 중복확인
    ========================= */
    $("#btnEmailCheck").click(function(){
        const email = $("#email").val().trim();
        const regEmail = /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i;

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

        if(email === originalEmail){
            $("#emailCheckResult").text("기존 이메일입니다.").css("color","green");
            b_emailcheck_click = true;
            return;
        }

        $.ajax({
            url: ctxPath + "/member/emailDuplicateCheck.lp",
            type: "post",
            data: { "email": email },
            dataType: "json",
            success: function(json){
                if(json.isExists){
                    $("#emailCheckResult").text("이미 사용중인 이메일입니다.").css("color","red");
                    b_emailcheck_click = false;
                } else {
                    $("#emailCheckResult").text("사용 가능한 이메일입니다.").css("color","green");
                    b_emailcheck_click = true;
                }
            }
        });
    });

    /* =========================
       이메일 수정 시 중복 재확인
    ========================= */
    $("#email").on("input", function(){
        if($(this).val().trim() !== originalEmail){
            b_emailcheck_click = false;
            $("#emailCheckResult").text("이메일 중복확인을 해주세요.").css("color","red");
        } else {
            b_emailcheck_click = true;
            $("#emailCheckResult").text("기존 이메일입니다.").css("color","green");
        }
    });

    /* =========================
       휴대폰 숫자만 입력
    ========================= */
    $("#hp2, #hp3").on("input", function(){
        this.value = this.value.replace(/[^0-9]/g, "");
    });
});

/* ======================================================
   내정보 수정 전송
====================================================== */
function goEdit(){
    const frm = document.editFrm;
    const name = $("#name").val().trim();
    const email = $("#email").val().trim();
    const hp2 = $("#hp2").val().trim();
    const hp3 = $("#hp3").val().trim();
    const postcode = $("#postcode").val().trim();
    const address = $("#address").val().trim();
    const detailAddress = $("#detailAddress").val().trim();

    // 1. 성명 검사
    if(name === ""){
        alert("성명을 입력하세요.");
        $("#name").focus();
        return;
    }

    // 2. 이메일 검사
    if(email === ""){
        alert("이메일을 입력하세요.");
        $("#email").focus();
        return;
    }
    if(!b_emailcheck_click){
        alert("이메일 중복확인을 해주세요.");
        return;
    }

    // 3. 휴대폰 검사
    if(hp2 === "" || hp3 === ""){
        alert("휴대폰 번호를 입력하세요.");
        $("#hp2").focus();
        return;
    }

    // 4. 주소 검사
    if(postcode === "" || address === ""){
        alert("우편번호 찾기를 통해 주소를 입력하세요.");
        return;
    }
    if(detailAddress === ""){
        alert("상세주소를 입력하세요.");
        $("#detailAddress").focus();
        return;
    }

    // 전송
    if(confirm("정보를 수정하시겠습니까?")){
        frm.method = "post";
        frm.action = ctxPath + "/my_info/my_info.lp";
        frm.submit();
    }
}