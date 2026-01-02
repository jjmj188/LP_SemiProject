
// ✅ 상품별 리뷰쓰기: 주문번호/상품번호/상품명 같이 넘김(나중에 DB 연결할 때 그대로 활용 가능)
    function openReviewPopup(orderId, prdId, prdName) {
      // 정적 html 기준. JSP로 바꾸면 review_write.jsp 로 변경하면 됨.
      const baseUrl = "/LP_SemiProject/my_info/review_write.jsp";

      const params = new URLSearchParams({
        orderId: orderId || "",
        prdId: prdId || "",
        prdName: prdName || ""
      });

      const url = baseUrl + "?" + params.toString();

      const name = "reviewPopup";
      const options = `
        width=600,
        height=600,
        top=100,
        left=700,
        scrollbars=yes,
        resizable=no
      `;
      window.open(url, name, options);
    }

    function toggleOrderDetails(btn){
      const orderCard = btn.closest(".order-card");
      const details = orderCard.querySelector(".order-details");
      const isOpen = orderCard.classList.toggle("open");

      details.setAttribute("aria-hidden", String(!isOpen));
      btn.textContent = isOpen ? "접기 ▲" : "펼치기 ▼";
    }
