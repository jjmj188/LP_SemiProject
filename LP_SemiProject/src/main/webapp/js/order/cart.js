

document.addEventListener("DOMContentLoaded", function () {

  
  
  /* =========================
     전체선택 / 개별선택
  ========================= */
  const checkAll = document.getElementById("checkAll");
  const itemChecks = document.querySelectorAll(".chkItem");

  if (checkAll) {
    checkAll.addEventListener("change", function () {
      itemChecks.forEach(chk => chk.checked = checkAll.checked);
    });
  }

  itemChecks.forEach(chk => {
    chk.addEventListener("change", function () {
      const checkedCount = document.querySelectorAll(".chkItem:checked").length;
      checkAll.checked = (checkedCount === itemChecks.length);
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
	  form.innerHTML = "";
      form.method = "post";
      form.action = "/LP_SemiProject/order/cartDeleteSelected.lp";

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

	  form.innerHTML = "";
      form.method = "post";
      form.action = "/LP_SemiProject/order/cartDeleteAll.lp";
      form.submit();
    });
  }

});

/* =========================
   수량 수정 (별도 함수)
========================= */
function updateCartQty(form) {
  const ctxPath = document.body.dataset.ctx;
  form.method = "post";
  form.action = ctxPath + "/order/cartUpdate.lp";
  form.submit();
}
