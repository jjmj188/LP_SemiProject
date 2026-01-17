<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<script src="<%=ctxPath%>/js/jquery-3.7.1.min.js"></script>

<script
	src="https://t1.daumcdn.net/mapjsapi/bundle/postcode/prod/postcode.v2.js"></script>
<script
	src="<%= ctxPath %>/13_daum_address_search/js/daum_address_search.js"></script>

<script src="https://service.iamport.kr/js/iamport.payment-1.1.2.js"></script>

<link rel="stylesheet" href="<%= ctxPath%>/css/order/buy.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/order/cart.css">

<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<script type="text/javascript">
$(function () {

  // =========================
  // 배송 요청사항
  // =========================
  $("#requestSelect").on("change", function () {
    const val = $(this).val();
    if (val === "직접 입력") {
      $("#requestText").val("").prop("readonly", false).focus();
    } else {
      $("#requestText").val(val).prop("readonly", true);
    }
  }).trigger("change");
  
  // =========================
  // 모드 판별(장바구니/바로구매)
  // =========================
  function isDirectBuyMode() {
    const v = document.getElementById("isDirectBuy")?.value;
    return v === "true"; // Buy.java에서 true로 내려옴
  }

  function getDirectInfo() {
    const pno = document.getElementById("directProductno")?.value;
    const qty = document.getElementById("directQty")?.value;

    return {
      productno: pno ? parseInt(pno, 10) : 0,
      qty: qty ? parseInt(qty, 10) : 0
    };
  }


  // =========================
  // cartno 읽기(장바구니 구매)
  // =========================
  function getCartnoList() {
    const arr = [];
    document.querySelectorAll(".selectedCartno").forEach(el => {
      const v = String(el.value || "").trim();
      if (v) arr.push(parseInt(v, 10));
    });
    return arr.filter(n => Number.isInteger(n) && n > 0);
  }


  function numberOnly(v) {
    return parseInt(String(v).replace(/[^0-9]/g, ""), 10) || 0;
  }

  function formatWon(n) {
    const x = Number(n) || 0;
    return x.toLocaleString("ko-KR");
  }

  function isBlank(v) {
    return v == null || String(v).trim() === "";
  }

  function getCtxPath() {
    const el = document.getElementById("ctxPath");
    return el ? el.value : "";
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


  // =========================
  //  금액 계산 규칙
  // 1P = 10원
  // 할인금액 = 기존할인 + (사용포인트 * 10원)
  // 총결제금액 = 주문금액 - 할인금액 + 배송비
  // =========================
  const POINT_WON_RATE = 10;
  const elSumTotalPrice = document.getElementById("sumTotalPrice");
  const elBaseDiscount  = document.getElementById("baseDiscountAmount");
  const elDeliveryFee   = document.getElementById("deliveryFee");

  const uiDiscountAmount = document.getElementById("uiDiscountAmount");
  const uiFinalPay       = document.getElementById("uiFinalPay");
  const hiddenUsePoint          = document.getElementById("usePoint");
  const hiddenPointDiscountWon  = document.getElementById("pointDiscountWon");
  const hiddenFinalPayAmount    = document.getElementById("finalPayAmount");

  function recomputeAndRender() {
    const sumTotalPrice = numberOnly(elSumTotalPrice ? elSumTotalPrice.value : 0);
    const baseDiscount  = numberOnly(elBaseDiscount ? elBaseDiscount.value : 0);
    const deliveryFee   = numberOnly(elDeliveryFee ? elDeliveryFee.value : 0);
    const usePoint = numberOnly(hiddenUsePoint ? hiddenUsePoint.value : 0);
    const pointDiscountWon = usePoint * POINT_WON_RATE;

    const discountAmount = baseDiscount + pointDiscountWon;
    let finalPay = sumTotalPrice - discountAmount + deliveryFee;

    if (finalPay < 0) finalPay = 0;

    if (hiddenPointDiscountWon) hiddenPointDiscountWon.value = String(pointDiscountWon);
    if (hiddenFinalPayAmount) hiddenFinalPayAmount.value = String(finalPay);

    if (uiDiscountAmount) uiDiscountAmount.textContent = "- ₩ " + formatWon(discountAmount);
    if (uiFinalPay) uiFinalPay.textContent = "₩ " + formatWon(finalPay);

    return {
      sumTotalPrice,
      baseDiscount,
      deliveryFee,
      usePoint,
      pointDiscountWon,
      discountAmount,
      finalPay
    };
  }


  // =========================
  // 포인트 input 처리
  // =========================
  const input = document.getElementById("pointInput");
  const chkUseAllPoint = document.getElementById("chkUseAllPoint");
  const maxPoint = input ? Number(input.dataset.maxPoint || 0) : 0;
  
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
    recomputeAndRender();
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
      if (chkUseAllPoint.checked) setPointNumber(maxPoint);
      else setPointNumber(0);
    });
  }


  // =========================
  // 초기 1회 렌더
  // =========================
  recomputeAndRender();
  
  // =========================
  // 구매하기 버튼 검증
  // =========================
  const btnBuy = document.getElementById("btnBuy");
  const requiredFields = [
    { el: document.getElementById("postcode"), name: "우편번호" },
    { el: document.getElementById("address"), name: "도로명 주소" },
    { el: document.getElementById("detailAddress"), name: "상세 주소" }
  ];
  
  function validateBeforePay() {
    const direct = isDirectBuyMode();
    // 주문상품 존재 체크 (모드별)
    if (!direct) {
      const cartnoList = getCartnoList();
      if (!cartnoList || cartnoList.length === 0) {
        alert("주문할 상품이 없습니다. 장바구니에서 상품을 선택 후 다시 시도해주세요.");
        return false;
      }
    } else {
      const info = getDirectInfo();
      if (!info.productno || !info.qty) {
        alert("바로구매 상품 정보가 없습니다. 상품 상세 페이지에서 다시 시도해주세요.");
        return false;
      }
    }
    // 주소 필수값
    for (const f of requiredFields) {
      if (!f.el) continue;
      if (isBlank(f.el.value)) {
        alert(f.name + "을(를) 입력해주세요.");
        f.el.focus();
        return false;
      }
    }

    // 배송 요청사항
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

    // 포인트
    const usedPoint = getPointNumber();
    if (usedPoint > maxPoint) {
      alert("보유 포인트보다 많이 사용할 수 없습니다.");
      setPointNumber(maxPoint);
      input && input.focus();
      return false;
    }

    // 최종결제금액 검증
    const calc = recomputeAndRender();
    if (calc.finalPay <= 0) {
      alert("결제금액이 올바르지 않습니다.");
      return false;
    }

    return true;
  }


  // =========================
  // 결제 + 서버 주문 저장
  // =========================
  let paying = false;
  if (btnBuy) {
    btnBuy.addEventListener("click", function () {
      if (!validateBeforePay()) return;
      if (paying) return;
      paying = true;

      const ctxPath = getCtxPath();
      if (!ctxPath) {
        alert("ctxPath가 없습니다. buy.jsp에 hidden #ctxPath가 필요합니다.");
        paying = false;
        return;
      }

      if (!window.IMP) {
         alert("아임포트 스크립트가 로드되지 않았습니다.");
        paying = false;
        return;
      }

      const direct = isDirectBuyMode();
      const cartnoList = direct ? [] : getCartnoList();
      const directInfo = direct ? getDirectInfo() : null;

      const calc = recomputeAndRender();

      //const payAmount = calc.finalPay;
      const payAmount = 1000; // 테스트용

      
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

      const merchantUid = "ord_" + Date.now();
      const IMP = window.IMP;
      IMP.init("imp66663353");

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

          usepoint: calc.usePoint,

          pointDiscountWon: calc.pointDiscountWon,
          baseDiscount: calc.baseDiscount,
          sumTotalPrice: calc.sumTotalPrice,
          deliveryFee: calc.deliveryFee,
          finalPayAmount: calc.finalPay,

          
          isDirectBuy: direct
        };
        if (direct) {
          payload.productno = directInfo.productno;
          payload.qty = directInfo.qty;
        } else {
          payload.cartnoList = cartnoList;
        }

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
</script>


<main class="buy-wrapper">
	<div class="buy-container">

		<section class="buy-left">
		
            <%-- [추가] 주문 상품 정보 리스트 (시각적 확인용) --%>
            <div class="buy-card" style="margin-bottom: 20px;">
                <h3>주문 상품 정보</h3>
                <div class="order-item-list" style="display: flex; flex-direction: column; gap: 15px;">
                    <c:forEach var="item" items="${cartList}">
                        <div class="order-item" style="display: flex; gap: 15px; align-items: center; border-bottom: 1px solid #eee; padding-bottom: 10px;">
                            
                            <%-- 이미지 경로 정규화 --%>
                            <c:set var="simpleFileName" value="${item.productimg}" />
                            <c:if test="${fn:contains(simpleFileName, 'images')}">
                                <c:set var="simpleFileName" value="${fn:replace(simpleFileName, '/images/productimg/', '')}" />
                                <c:set var="simpleFileName" value="${fn:replace(simpleFileName, 'images/productimg/', '')}" />
                            </c:if>
                            
                            <div class="img-box" style="width: 60px; height: 60px; border-radius: 4px; overflow: hidden; border: 1px solid #ddd;">
                                <img src="<%= ctxPath%>/images/productimg/${simpleFileName}" alt="${item.productname}" style="width: 100%; height: 100%; object-fit: cover;">
                            </div>
                            
                            <div class="info-box">
                                <p style="font-weight: bold; margin: 0 0 5px 0;">${item.productname}</p>
                                <p style="font-size: 14px; color: #666; margin: 0;">
                                    수량: ${item.qty}개 | 
                                    ₩ <fmt:formatNumber value="${item.totalPrice}" pattern="#,###"/>
                                </p>
                            </div>
                        </div>
                    </c:forEach>
                </div>
            </div>
            <%-- [추가 끝] --%>
		
			<div class="buy-card">
				<h3>주문자 / 배송 정보</h3>

				<div class="form-group">
					<label>주문자 이름</label> <input type="text" placeholder="이름 입력"
						value="${sessionScope.loginuser.name}" readonly>
				</div>

				<div class="form-group">
					<label>연락처</label>
					<div class="hp-row">
						<input type="text" value="010" readonly> - <input
							type="text" name="hp2" id="hp2" maxlength="4"
							value="${fn:substring(sessionScope.loginuser.mobile,3,7)}"
							readonly> - <input type="text" name="hp3" id="hp3"
							maxlength="4"
							value="${fn:substring(sessionScope.loginuser.mobile,7,11)}"
							readonly>
					</div>
				</div>

				<div class="form-group">
					<label>이메일</label> <input type="email"
						placeholder="email@example.com"
						value="${sessionScope.loginuser.email}" readonly>
				</div>

				<hr>

				<div class="form-group">
					<label class="title">포인트 사용</label> <input type="text"
						class="point-input" value="0 P" id="pointInput"
						data-max-point="${sessionScope.loginuser.point}">

					<div class="point-check-row">
						<label> <input type="checkbox" id="chkUseAllPoint">
							포인트 전부 사용하기
						</label>
					</div>

				</div>

				<hr>

				<div class="form-group">
					<label>주소</label>

					<div class="address-row">
						<input type="text" id="postcode" name="postcode"
							placeholder="우편번호" readonly
							value="${sessionScope.loginuser.postcode}">

						<button type="button" class="btn-outline" onclick="openDaumPOST()">
							우편번호 찾기</button>
					</div>

					<input type="text" id="address" name="address" class="form-group"
						placeholder="도로명 주소" readonly
						value="${sessionScope.loginuser.address}"> <input
						type="text" id="detailAddress" name="detailaddress"
						class="form-group" placeholder="상세 주소"
						value="${sessionScope.loginuser.detailaddress}"> <input
						type="text" id="extraAddress" name="extraaddress"
						class="form-group" placeholder="참고 항목"
						value="${sessionScope.loginuser.extraaddress}">
				</div>

				<div class="form-group">
					<label>배송 요청사항</label> <select id="requestSelect">
						<option value="">선택해주세요</option>
						<option value="문 앞에 놓아주세요">문 앞에 놓아주세요</option>
						<option value="경비실에 맡겨주세요">경비실에 맡겨주세요</option>
						<option value="배송 전 연락주세요">배송 전 연락주세요</option>
						<option value="직접 입력">직접 입력</option>
					</select>
				</div>

				<div class="form-group">
					<textarea id="requestText" placeholder="배송 요청사항을 입력하세요"></textarea>
				</div>

			</div>
		</section>

		<aside class="buy-right">
			<section class="summary-card">
				<h3>결제 정보</h3>

				<div class="summary-row">
					<span>주문금액</span> <span id="uiOrderAmount">₩ <fmt:formatNumber
							value="${sumTotalPrice}" pattern="#,###" /></span>
				</div>

				<div class="summary-row">
					<span>할인금액</span> <span id="uiDiscountAmount">- ₩ <fmt:formatNumber
							value="${discountAmount}" pattern="#,###" /></span>
				</div>

				<div class="summary-row">
					<span>배송비</span> <span id="uiDeliveryFee">₩ <fmt:formatNumber
							value="${deliveryFee}" pattern="#,###" /></span>
				</div>

				<hr>

				<div class="summary-row total">
					<span>총 결제금액</span> <span id="uiFinalPay">₩ <fmt:formatNumber
							value="${finalPayAmount}" pattern="#,###" /></span>
				</div>

				<div class="summary-row point">
					<span>적립 포인트</span> <span><fmt:formatNumber
							value="${sumTotalPoint}" pattern="#,###" />P</span>
				</div>

				<div class="action-buttons">
					<c:if test="${not isDirectBuy}">
					  <button class="cart"
					    onclick="location.href='<%= ctxPath%>/order/cart.lp'">
					    더 담으러가기
					  </button>
					</c:if>

					<button type="button" class="buy" id="btnBuy">구매하기</button>
				</div>
			</section>

			<c:forEach var="cno" items="${cartnoArr}">
				<input type="hidden" class="selectedCartno" value="${cno}">
			</c:forEach>


			<input type="hidden" id="isDirectBuy" value="${isDirectBuy}" />
			<c:if test="${isDirectBuy}">
				<c:forEach var="item" items="${cartList}" varStatus="st">
					<c:if test="${st.first}">
						<input type="hidden" id="directProductno"
							value="${item.productno}" />
						<input type="hidden" id="directQty" value="${item.qty}" />
					</c:if>
				</c:forEach>
			</c:if>


			<input type="hidden" id="ctxPath" value="<%=ctxPath%>">

			<input type="hidden" id="sumTotalPrice" value="${sumTotalPrice}">

			<input type="hidden" id="baseDiscountAmount"
				value="${discountAmount}">

			<input type="hidden" id="deliveryFee" value="${deliveryFee}">

			<input type="hidden" id="sumTotalPoint" value="${sumTotalPoint}">

			<input type="hidden" id="usePoint" value="0">

			<input type="hidden" id="pointDiscountWon" value="0">

			<input type="hidden" id="finalPayAmount" value="${finalPayAmount}">

			<input type="hidden" id="deliveryRequestFinal" value="">
		</aside>

	</div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />