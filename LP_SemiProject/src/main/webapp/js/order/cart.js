document.addEventListener("DOMContentLoaded", function () {

  function getContextPath() {
    // 1) meta ctxPath 우선
    const meta = document.querySelector('meta[name="ctxPath"]');
    if (meta && meta.content) return meta.content;

    // 2) body data-ctx (있으면)
    const fromBody = document.body && document.body.dataset ? document.body.dataset.ctx : "";
    if (fromBody) return fromBody;

    // 3) fallback: /프로젝트명 추정
    const p = window.location.pathname || "";
    const parts = p.split("/").filter(Boolean);
    return parts.length > 0 ? "/" + parts[0] : "";
  }

  const ctxPath = getContextPath();


  /* =========================
     숫자 포맷
  ========================= */
  function formatNumber(n) {
    return (n || 0).toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
  }


  /* =========================
     결제정보 업데이트(선택된 것만)
  ========================= */
  function updateSummary() {
    const checked = document.querySelectorAll(".chkItem:checked");

    let sumPrice = 0;
    let sumPoint = 0;

    checked.forEach(chk => {
      sumPrice += parseInt(chk.dataset.price || "0", 10);
      sumPoint += parseInt(chk.dataset.point || "0", 10);
    });

    
    const shipFee = (checked.length > 0) ? 3000 : 0;
    const payTotal = sumPrice + shipFee;

    const elSumPrice = document.getElementById("sumPrice");
    const elSumPoint = document.getElementById("sumPoint");
    const elShipFee  = document.getElementById("shipFee");
    const elPayTotal = document.getElementById("payTotal");

    if (elSumPrice) elSumPrice.textContent = formatNumber(sumPrice);
    if (elSumPoint) elSumPoint.textContent = formatNumber(sumPoint);
    if (elShipFee)  elShipFee.textContent  = formatNumber(shipFee);
    if (elPayTotal) elPayTotal.textContent = formatNumber(payTotal);
  }


  /* =========================
     전체선택 / 개별선택
  ========================= */
  const checkAll = document.getElementById("checkAll");
  const itemChecks = document.querySelectorAll(".chkItem");

  if (checkAll) {
    checkAll.addEventListener("change", function () {
      itemChecks.forEach(chk => chk.checked = checkAll.checked);
      updateSummary();
    });
  }

  itemChecks.forEach(chk => {
    chk.addEventListener("change", function () {
      const checkedCount = document.querySelectorAll(".chkItem:checked").length;
      if (checkAll) checkAll.checked = (checkedCount === itemChecks.length);
      updateSummary();
    });
  });


  /* =========================
     선택삭제 / 전체삭제
  ========================= */
  const form = document.getElementById("cartDeleteForm");
  const btnSel = document.getElementById("btnDeleteSelected");
  const btnAll = document.getElementById("btnDeleteAll");

  if (btnSel) {
    btnSel.addEventListener("click", function () {
      const checked = document.querySelectorAll(".chkItem:checked");

      if (checked.length === 0) {
        alert("삭제할 상품을 선택하세요.");
        return;
      }

      form.querySelectorAll("input[name='cartno']").forEach(x => x.remove());

      form.method = "post";
      form.action = ctxPath + "/order/cartDeleteSelected.lp";

      checked.forEach(chk => {
        const input = document.createElement("input");
        input.type = "hidden";
        input.name = "cartno";
        input.value = chk.value;
        form.appendChild(input);
      });

      form.submit();
    });
  }

  if (btnAll) {
    btnAll.addEventListener("click", function () {
      if (!confirm("장바구니를 전체 삭제할까요?")) return;

      // hidden 제거
      form.querySelectorAll("input[name='cartno']").forEach(x => x.remove());

      form.method = "post";
      form.action = ctxPath + "/order/cartDeleteAll.lp";
      form.submit();
    });
  }


  /* =========================
     주문 폼 제출
  ========================= */
  const goBuyForm = document.getElementById("goBuyForm");

  if (goBuyForm) {
    goBuyForm.addEventListener("submit", function (e) {
      const checked = document.querySelectorAll(".chkItem:checked");
      if (checked.length === 0) {
        alert("주문할 상품을 선택해주세요.");
        e.preventDefault();
        return;
      }

      this.querySelectorAll("input[name='cartno']").forEach(x => x.remove());

      checked.forEach(chk => {
        const hidden = document.createElement("input");
        hidden.type = "hidden";
        hidden.name = "cartno";
        hidden.value = chk.value;
        this.appendChild(hidden);
      });
    });
  }

  updateSummary();
});


/* =========================
   수량 수정 
========================= */
function updateCartQty(form) {
  // ctxPath 확보
  const meta = document.querySelector('meta[name="ctxPath"]');
  const ctxPath = meta && meta.content ? meta.content : "";

  form.method = "post";
  form.action = ctxPath + "/order/cartUpdate.lp";
  form.submit();
}
