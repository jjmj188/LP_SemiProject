let b_emailcheck_click = false;
let originalEmail = "";

$(function () {

    // 🔥 기존 이메일 저장 (페이지 로딩 시)
    originalEmail = $("#email").val();

    /* =========================
       이메일 중복확인
    ========================= */
    $("#btnEmailCheck").on("click", function () {

        const email = $("#email").val().trim();
        const regEmail =
            /^[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,}$/;

        if (email === "") {
            alert("이메일을 입력하세요.");
            $("#email").focus();
            return;
        }

        if (!regEmail.test(email)) {
            alert("이메일 형식이 올바르지 않습니다.");
            $("#email").focus();
            return;
        }

        // 기존 이메일이면 중복확인 필요 없음
        if (email === originalEmail) {
            $("#emailCheckResult")
                .text("기존 이메일입니다.")
                .css("color", "green");
            b_emailcheck_click = true;
            return;
        }

        $.ajax({
            url: ctxPath + "/member/emailDuplicateCheck.lp",
            type: "post",
            data: { email: email },
            dataType: "json",
            success: function (json) {
                if (json.isExists) {
                    $("#emailCheckResult")
                        .text("이미 사용중인 이메일입니다.")
                        .css("color", "red");
                    b_emailcheck_click = false;
                } else {
                    $("#emailCheckResult")
                        .text("사용 가능한 이메일입니다.")
                        .css("color", "green");
                    b_emailcheck_click = true;
                }
            }
        });
    });

    /* =========================
       이메일 수정 시 중복확인 초기화
    ========================= */
    $("#email").on("input", function () {
        b_emailcheck_click = false;
        $("#emailCheckResult")
            .text("이메일 중복확인을 해주세요.")
            .css("color", "red");
    });

    /* =========================
       휴대폰 숫자만 입력
    ========================= */
    $("#hp2, #hp3").on("input", function () {
        this.value = this.value.replace(/[^0-9]/g, "");
    });

});

/* ======================================================
   회원정보 수정 전송
====================================================== */
function goEdit() {

    // 1️ 성명 검사
    const name = $("#name").val().trim();
    const regName = /^([가-힣]{2,10}|[a-zA-Z]{2,20})$/;

    if (name === "") {
        alert("성명을 입력하세요.");
        $("#name").focus();
        return;
    }

    if (!regName.test(name)) {
        alert("성명은 한글 2~10자 또는 영문 2~20자만 가능합니다.");
        $("#name").focus();
        return;
    }

    // 2️⃣ 이메일 검사
    const email = $("#email").val().trim();

    if (email === "") {
        alert("이메일을 입력하세요.");
        $("#email").focus();
        return;
    }

    // 이메일이 변경된 경우만 중복확인 강제
    if (email !== originalEmail && !b_emailcheck_click) {
        alert("이메일 중복확인을 해주세요.");
        return;
    }

    // 3️⃣ 휴대폰 검사
    const hp2 = $("#hp2").val().trim();
    const hp3 = $("#hp3").val().trim();

    if (!/^\d{4}$/.test(hp2) || !/^\d{4}$/.test(hp3)) {
        alert("연락처는 숫자 4자리씩 입력하세요.");
        $("#hp2").focus();
        return;
    }

    // 4️⃣ 폼 전송
    const frm = document.forms["editFrm"];
    frm.method = "post";
    frm.action = ctxPath + "/member/member_info.lp";
    frm.submit();
}
