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
  const chkUseAllPoint = document.getElementById("chkUseAllPoint");

  // input에 data-max-point="${sessionScope.loginuser.point}" 가 있어야 함
  const maxPoint = input ? Number(input.dataset.maxPoint || 0) : 0;

  // hidden usePoint(서버로 보낼 숫자용)
  const hiddenUsePoint = document.getElementById("usePoint");

  function normalizePoint(value) {
    const num = String(value).replace(/[^0-9]/g, "");
    return (num === "" ? "" : num) + " P";
  }

  function getPointNumber() {
    if (!input) return 0;
    const num = String(input.value || "").replace(/[^0-9]/g, "");
    return num === "" ? 0 : Number(num);
  }

  function syncHiddenUsePoint(num) {
    if (hiddenUsePoint) hiddenUsePoint.value = String(num || 0);
  }

  function setPointNumber(n) {
    if (!input) return;

    let safe = Number(n);
    if (Number.isNaN(safe)) safe = 0;
    if (safe < 0) safe = 0;
    if (safe > maxPoint) safe = maxPoint;

    input.value = (safe === 0 ? "" : String(safe)) + " P";

    const pos = (safe === 0 ? "" : String(safe)).length;
    input.setSelectionRange(pos, pos);

    if (chkUseAllPoint) {
      chkUseAllPoint.checked = (maxPoint > 0 && safe === maxPoint);
    }

    // ✅ hidden 동기화 (중요)
    syncHiddenUsePoint(safe);
  }

  function clampPoint(showAlert) {
    if (!input) return;

    let n = getPointNumber();
    if (n > maxPoint) {
      n = maxPoint;
      setPointNumber(n);
      if (showAlert) alert("보유 포인트보다 많이 사용할 수 없습니다.");
    } else {
      if (chkUseAllPoint) chkUseAllPoint.checked = (maxPoint > 0 && n === maxPoint);
      syncHiddenUsePoint(n);
    }
  }

  if (input) {
    // 최초 값 포맷 + hidden 반영
    input.value = normalizePoint(input.value);
    syncHiddenUsePoint(getPointNumber());

    input.addEventListener("input", () => {
      const num = input.value.replace(/[^0-9]/g, "");
      input.value = normalizePoint(input.value);

      const pos = num.length;
      input.setSelectionRange(pos, pos);

      clampPoint(false);
    });

    input.addEventListener("blur", () => {
      clampPoint(true);
    });

    input.addEventListener("keydown", (e) => {
      const numLength = input.value.replace(/[^0-9]/g, "").length;

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

  if (chkUseAllPoint) {
    chkUseAllPoint.addEventListener("change", () => {
      if (chkUseAllPoint.checked) {
        setPointNumber(maxPoint);
      } else {
        setPointNumber(0);
      }
    });
  }


  // =========================
  // 구매하기 버튼: 필수값 검증
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
    for (const f of requiredFields) {
      if (!f.el) continue;
      if (isBlank(f.el.value)) {
        alert(f.name + "을(를) 입력해주세요.");
        f.el.focus();
        return false;
      }
    }

    const reqVal = $("#requestSelect").val();
    const reqText = $("#requestText").val();

    if (isBlank(reqVal)) {
      alert("배송 요청사항을 선택해주세요.");
      document.getElementById("requestSelect").focus();
      return false;
    }

    if (reqVal === "직접 입력" && isBlank(reqText)) {
      alert("배송 요청사항을 입력해주세요.");
      document.getElementById("requestText").focus();
      return false;
    }

    const usedPoint = getPointNumber();
    if (usedPoint > maxPoint) {
      alert("보유 포인트보다 많이 사용할 수 없습니다.");
      setPointNumber(maxPoint);
      input && input.focus();
      return false;
    }

    return true;
  }


  // =========================
  // 결제(아임포트) + 서버 주문 저장
  // =========================

  function getCtxPath() {
    const el = document.getElementById("ctxPath");
    return el ? el.value : "";
  }

  function numberOnly(v) {
    return parseInt(String(v).replace(/[^0-9]/g, ""), 10) || 0;
  }

  function getFinalDeliveryRequest() {
    return ($("#requestText").val() || "").trim();
  }

  function postJson(url, data) {
    return fetch(url, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(data)
    }).then(function (res) {
      if (!res.ok) throw new Error("HTTP " + res.status);
      return res.json();
    });
  }

  let paying = false;

  if (btnBuy) {
    btnBuy.addEventListener("click", function () {
      if (!validateBeforePay()) return;
      if (paying) return;
      paying = true;

      const ctxPath = getCtxPath();
	  
	  // ✅ 클릭 시점에서 hidden/입력값 전부 한번에 확인
	        console.log("========== [BUY CLICK CHECK] ==========");
	        console.log("ctxPath(hidden) =", ctxPath);
	        console.log("sumTotalPrice(hidden) =", $("#sumTotalPrice").val());
	        console.log("deliveryFee(hidden) =", $("#deliveryFee").val());
	        console.log("usePoint(hidden) =", $("#usePoint").val());
	        console.log("postcode =", $("#postcode").val());
	        console.log("address =", $("#address").val());
	        console.log("detailAddress =", $("#detailAddress").val());
	        console.log("extraAddress =", $("#extraAddress").val());
	        console.log("deliveryrequest(text) =", getFinalDeliveryRequest());
	        console.log("=======================================");
	  
      if (!ctxPath) {
        alert("ctxPath가 없습니다. buy.jsp에 hidden #ctxPath가 필요합니다.");
        paying = false;
        return;
      }

      if (!window.IMP) {
        alert("아임포트 스크립트가 로드되지 않았습니다. buy.jsp에서 iamport.payment.js를 buy.js보다 먼저 추가하세요.");
        paying = false;
        return;
      }

      // 금액 계산 (서버에서도 반드시 재검증할 것)
      const sumTotalPrice = numberOnly($("#sumTotalPrice").val());
      const deliveryFee = numberOnly($("#deliveryFee").val());
      const usepoint = numberOnly($("#usePoint").val()); // hidden 동기화되어 있어야 함

      //const payAmount = sumTotalPrice + deliveryFee - usepoint;
	  const payAmount = 100;//테스트용

      if (payAmount <= 0) {
        alert("결제금액이 올바르지 않습니다.");
        paying = false;
        return;
      }

      // 배송 정보
      const postcode = ($("#postcode").val() || "").trim();
      const address = ($("#address").val() || "").trim();
      const detailaddress = ($("#detailAddress").val() || "").trim();
      const extraaddress = ($("#extraAddress").val() || "").trim();
      const deliveryrequest = getFinalDeliveryRequest();

      // 구매자 정보
      const buyer_email = $('input[type="email"]').val() || "";
      const buyer_name = $('input[placeholder="이름 입력"]').val() || "";
      const buyer_tel = "010" + ($("#hp2").val() || "") + ($("#hp3").val() || "");

      // 주문 단위 고유값
      const merchantUid = "ord_" + Date.now();

      const IMP = window.IMP;
      IMP.init("imp66663353"); // 너 가맹점 식별코드

      IMP.request_pay({
        pg: "html5_inicis",
        pay_method: "card",
        merchant_uid: merchantUid,
        name: "주문 결제",
        amount: payAmount,
        buyer_email: buyer_email,
        buyer_name: buyer_name,
        buyer_tel: buyer_tel,
        buyer_addr: address + " " + detailaddress,
        buyer_postcode: postcode
      }, function (rsp) {
		
		/*// ✅ 아임포트 응답 전체 확인
		        console.log("[IMP rsp]", rsp);*/
		
        if (!rsp.success) {
          alert("결제에 실패하였습니다: " + (rsp.error_msg || ""));
          paying = false;
          return;
        }

        const payload = {
          imp_uid: rsp.imp_uid,
          merchant_uid: rsp.merchant_uid,
          paid_amount: rsp.paid_amount,

          postcode: postcode,
          address: address,
          detailaddress: detailaddress,
          extraaddress: extraaddress,
          deliveryrequest: deliveryrequest,

          usepoint: usepoint
        };
		
		/*// ✅ 서버로 보내는 값 최종 확인 (요청 URL까지 같이)
		       const apiUrl = ctxPath + "/order/pay.lp"; // 여기 엔드포인트가 맞는지 확인 필요
		       console.log("========== [PAYLOAD to server] ==========");
		       console.log("POST URL =", apiUrl);
		       console.log(payload);
		       console.log("payload(JSON) =", JSON.stringify(payload));
		       console.log("=========================================");*/
		
        postJson(ctxPath + "/order/pay.lp", payload)
          .then(function (json) {
            if (json && json.n === 1) {
              location.href = json.loc;
            } else {
              alert((json && json.message) ? json.message : "주문 저장에 실패했습니다.");
            }
          })
          .catch(function (e) {
            console.error(e);
            alert("서버 저장 중 오류가 발생했습니다.");
          })
          .finally(function () {
            paying = false;
          });
      });
    });
  }

});
