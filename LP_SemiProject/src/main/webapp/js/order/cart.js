function updateCartQty(form) {
  form.method = "post";
  form.action = form.dataset.ctx + "/order/cartUpdate.lp"; // 아래에서 data-ctx 쓰면 좋음
  form.submit();
}
