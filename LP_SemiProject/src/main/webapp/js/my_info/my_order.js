// 상품별 리뷰쓰기: 주문번호/상품번호/상품명 같이 넘김
function openReviewPopup(btn) {

  const ctxPath = "/LP_SemiProject";
  const baseUrl = ctxPath + "/my_info/review_write.lp";

  const prdName   = btn.dataset.prdname || "";
  const prdImg    = btn.dataset.prdimg || "";
  const lineprice = btn.dataset.lineprice || "";

  const params = new URLSearchParams({
    prdName: prdName,
    prdImg: prdImg,
    price: lineprice
  });

  const url = baseUrl + "?" + params.toString();

  // ✅ 상품마다 다른 팝업으로 열고 싶으면 name을 다르게
  const name = "reviewPopup_" + String(lineprice) + "_" + Date.now();

  const width = 600;
  const height = 600;
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
	
	// 송장 팝업 열기
	
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


