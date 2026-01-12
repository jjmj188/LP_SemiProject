
// ✅ 상품별 리뷰쓰기: 주문번호/상품번호/상품명 같이 넘김(나중에 DB 연결할 때 그대로 활용 가능)
function openReviewPopup(orderId, prdId, prdName) {

  const baseUrl = "/LP_SemiProject/my_info/review_write.lp";

  const params = new URLSearchParams({
    orderId: orderId || "",
    prdId: prdId || "",
    prdName: prdName || ""
  });

  const url = baseUrl + "?" + params.toString();

  const name = "reviewPopup";
  const width = 600;
  const height = 600;

  // ✅ 화면 정가운데 계산
  const left = Math.max(0, (window.screen.width - width) / 2);
  const top  = Math.max(0, (window.screen.height - height) / 2);

  const options =
    "width=" + width +
    ",height=" + height +
    ",left=" + left +
    ",top=" + top +
    ",scrollbars=yes,resizable=no";

  window.open(url, name, options);
}

    function toggleOrderDetails(btn){
      const orderCard = btn.closest(".order-card");
      const details = orderCard.querySelector(".order-details");
      const isOpen = orderCard.classList.toggle("open");

      details.setAttribute("aria-hidden", String(!isOpen));
      btn.textContent = isOpen ? "접기 ▲" : "펼치기 ▼";
    }
	
	// ✅ 송장 팝업 열기
	
	function openTrackingPopup(btn) {

	  const orderno = btn.dataset.orderno;
	  if (!orderno) {
	    alert("주문번호를 찾을 수 없습니다.");
	    return;
	  }

	  const ctxPath = "/LP_SemiProject";

	  const url = ctxPath + "/my_info/tracking_popup.lp?orderno=" + encodeURIComponent(orderno);

	  const name = "trackingPopup";
	  const width = 520;
	  const height = 520;
	  const left = Math.max(0, (window.screen.width - width) / 2);
	  const top  = Math.max(0, (window.screen.height - height) / 2);

	  const options =
	    "width=" + width +
	    ",height=" + height +
	    ",left=" + left +
	    ",top=" + top +
	    ",scrollbars=yes,resizable=no";

	  window.open(url, name, options);
	}


