$(function () {

  // =========================
  // 배송 요청사항 select -> textarea
  // =========================
  $("#requestSelect").on("change", function () {
    const val = $(this).val();

    if (val === "직접 입력") {
      $("#requestText").val("").prop("readonly", false).focus();
    } else {
      $("#requestText").val(val).prop("readonly", true);
    }
  }).trigger("change"); // 최초 상태 반영


  // =========================
  // 포인트 input: "숫자 P" 유지 (text 타입)
  // + 보유포인트 초과 입력 방지
  // + 전부 사용 체크 시 자동 입력
  // =========================
  const input = document.getElementById("pointInput");
  const chkUseAllPoint = document.getElementById("chkUseAllPoint"); // 체크박스에 id 부여 필요

  // ✅ JSP에서 보유포인트 넘기는 방식(둘 중 하나 선택)
  // 1) input에 data-max-point="${sessionScope.loginuser.point}" 넣는 경우:
  const maxPoint = input ? Number(input.dataset.maxPoint || 0) : 0;

  // 2) data 속성 안 쓰고 바로 JSP로 받는 경우(원하면 이걸로 바꿔도 됨):
  // const maxPoint = Number("${sessionScope.loginuser.point}" || 0);

  function normalizePoint(value) {
    const num = String(value).replace(/[^0-9]/g, "");
    return (num === "" ? "" : num) + " P";
  }

  function getPointNumber() {
    if (!input) return 0;
    const num = String(input.value || "").replace(/[^0-9]/g, "");
    return num === "" ? 0 : Number(num);
  }

  function setPointNumber(n) {
    if (!input) return;
    let safe = Number(n);
    if (Number.isNaN(safe)) safe = 0;
    if (safe < 0) safe = 0;
    if (safe > maxPoint) safe = maxPoint;

    // 숫자가 없으면 " P" 형태로 두고 싶으면 아래처럼 처리
    input.value = (safe === 0 ? "" : String(safe)) + " P";

    const pos = (safe === 0 ? "" : String(safe)).length;
    input.setSelectionRange(pos, pos);

    if (chkUseAllPoint) {
      chkUseAllPoint.checked = (maxPoint > 0 && safe === maxPoint);
    }
  }

  function clampPoint(showAlert) {
    if (!input) return;
    let n = getPointNumber();
    if (n > maxPoint) {
      n = maxPoint;
      setPointNumber(n);
      if (showAlert) alert("보유 포인트보다 많이 사용할 수 없습니다.");
    } else {
      // 체크박스 동기화만
      if (chkUseAllPoint) chkUseAllPoint.checked = (maxPoint > 0 && n === maxPoint);
    }
  }

  if (input) {
    input.value = normalizePoint(input.value);

    input.addEventListener("input", () => {
      // 1) 숫자+P 포맷 유지
      const num = input.value.replace(/[^0-9]/g, "");
      input.value = normalizePoint(input.value);

      // 2) 커서 항상 숫자 끝
      const pos = num.length;
      input.setSelectionRange(pos, pos);

      // 3) 보유포인트 초과 제한(알림은 과하게 뜨니 input 중에는 알림 없이 clamp만)
      clampPoint(false);
    });

    input.addEventListener("blur", () => {
      // blur 시에는 초과면 알림 띄우고 제한
      clampPoint(true);
    });

    input.addEventListener("keydown", (e) => {
      const numLength = input.value.replace(/[^0-9]/g, "").length;

      // 커서가 P쪽으로 가면 막기
      if (input.selectionStart > numLength || input.selectionEnd > numLength) {
        input.setSelectionRange(numLength, numLength);
        e.preventDefault();
      }
    });

    input.addEventListener("click", () => {
      const numLength = input.value.replace(/[^0-9]/g, "").length;
      input.setSelectionRange(numLength, numLength);
    });
  }

  // ✅ 전부 사용 체크박스 처리
  if (chkUseAllPoint) {
    chkUseAllPoint.addEventListener("change", () => {
      if (chkUseAllPoint.checked) {
        setPointNumber(maxPoint); // 전부 입력
      } else {
        setPointNumber(0);        // 해제 시 0(원하면 ""로 유지됨)
      }
    });
  }


  // =========================
  // 구매하기 버튼: 포인트 제외 필수값 검증
  // =========================
  const btnBuy = document.getElementById("btnBuy");

  const requiredFields = [
    { el: document.getElementById("postcode"), name: "우편번호" },
    { el: document.getElementById("address"), name: "도로명 주소" },
    { el: document.getElementById("detailAddress"), name: "상세 주소" }
  ];

  function isBlank(v) {
    return v == null || String(v).trim() === "";
  }

  function validateBeforePay() {
    // 1) 주소 필수 체크
    for (const f of requiredFields) {
      if (!f.el) continue;
      if (isBlank(f.el.value)) {
        alert(f.name + "을(를) 입력해주세요.");
        f.el.focus();
        return false;
      }
    }

    // 2) 배송 요청사항 "선택해주세요"면 막기
    const reqVal = $("#requestSelect").val();
    const reqText = $("#requestText").val();

    if (isBlank(reqVal)) {
      alert("배송 요청사항을 선택해주세요.");
      document.getElementById("requestSelect").focus();
      return false;
    }

    // 3) "직접 입력"일 때만 textarea 필수
    if (reqVal === "직접 입력" && isBlank(reqText)) {
      alert("배송 요청사항을 입력해주세요.");
      document.getElementById("requestText").focus();
      return false;
    }

    // ✅ 4) 포인트 최종 검증(보유포인트 초과 방지 - 안전망)
    const usedPoint = getPointNumber();
    if (usedPoint > maxPoint) {
      alert("보유 포인트보다 많이 사용할 수 없습니다.");
      setPointNumber(maxPoint);
      input && input.focus();
      return false;
    }

    return true;
  }

  if (btnBuy) {
    btnBuy.addEventListener("click", function () {
      if (!validateBeforePay()) return;

      // 여기 통과하면 진행
      location.href = "<%= ctxPath %>/order/pay.lp";
	  
	  
	  // 전송 (POST)
	    	const frm = document.getElementById("inquiryForm");
	    	frm.method = "post";
	  	frm.action = ctxPath + "/my_info/my_inquiry.lp";
	    	frm.submit();
    });
  }

});
