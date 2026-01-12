"use strict";

(function () {
  function getCtxPath() {
    // window.__CTX_PATH__ 를 JSP에서 미리 세팅해두면 가장 안전
    return (window.__CTX_PATH__ ? window.__CTX_PATH__ : "/LP_SemiProject");
  }

  // ===== 상세 펼치기 =====
  function toggleOrderDetails(btn) {
    if (!btn) return;

    const orderCard = btn.closest(".order-card");
    if (!orderCard) return;

    const details = orderCard.querySelector(".order-details");
    if (!details) return;

    const isOpen = orderCard.classList.toggle("open");

    details.setAttribute("aria-hidden", String(!isOpen));
    btn.textContent = isOpen ? "접기 ▲" : "펼치기 ▼";
  }

  // ===== 송장 팝업 =====
  function openTrackingPopup(btn) {
    if (!btn) return;

    const orderno = btn.dataset.orderno;
    if (!orderno) {
      alert("주문번호를 찾을 수 없습니다.");
      return;
    }

    const ctxPath = getCtxPath();
    const url =
      ctxPath +
      "/my_info/tracking_popup.lp?orderno=" +
      encodeURIComponent(orderno);

    const name = "trackingPopup";
    const width = 520;
    const height = 520;
    const left = Math.max(0, (window.screen.width - width) / 2);
    const top = Math.max(0, (window.screen.height - height) / 2);

    const options =
      "width=" +
      width +
      ",height=" +
      height +
      ",left=" +
      left +
      ",top=" +
      top +
      ",scrollbars=yes,resizable=no";

    window.open(url, name, options);
  }

  // ===== 리뷰 모달 =====
  function closeReviewModal() {
    const modal = document.getElementById("reviewModal");
    if (!modal) return;

    modal.classList.remove("open");
    modal.setAttribute("aria-hidden", "true");
    modal.dataset.lastBtnId = "";

    const body = modal.querySelector(".panel-body");
    if (body) body.innerHTML = '<div class="loading">불러오는 중...</div>';
  }

  async function openReviewModal(btn) {
    if (!btn) return;

    // done/disabled면 아예 동작 안 하게
    if (btn.disabled || btn.classList.contains("done")) return;

    const orderno = btn.dataset.orderno;
    const productno = btn.dataset.productno;

    if (!orderno || !productno) {
      alert("리뷰 정보를 열 수 없습니다. (주문/상품 식별값 누락)");
      return;
    }

    if (!btn.id) btn.id = "btnReview_" + orderno + "_" + productno;

    const ctxPath = getCtxPath();
    const url =
      ctxPath +
      "/my_info/review_write.lp?orderno=" +
      encodeURIComponent(orderno) +
      "&productno=" +
      encodeURIComponent(productno);

    const modal = document.getElementById("reviewModal");
    if (!modal) {
      alert("리뷰 모달 요소(#reviewModal)를 찾을 수 없습니다.");
      return;
    }

    const body = modal.querySelector(".panel-body");
    if (!body) {
      alert("리뷰 모달 본문(.panel-body)을 찾을 수 없습니다.");
      return;
    }

    modal.classList.add("open");
    modal.setAttribute("aria-hidden", "false");
    modal.dataset.lastBtnId = btn.id;

    body.innerHTML = '<div class="loading">불러오는 중...</div>';

    try {
      const res = await fetch(url, {
        method: "GET",
        headers: { "X-Requested-With": "XMLHttpRequest" },
      });

      const ct = (res.headers.get("content-type") || "").toLowerCase();

      // 서버가 JSON(에러) 내려주면 alert
      if (ct.includes("application/json")) {
        const data = await res.json();
        alert(data && data.msg ? data.msg : "리뷰 창을 열 수 없습니다.");
        closeReviewModal();
        return;
      }

      const html = await res.text();
      body.innerHTML = html;

      bindReviewModalEvents();
    } catch (e) {
      console.error(e);
      alert("리뷰 창을 불러오지 못했습니다.");
      closeReviewModal();
    }
  }

  function bindReviewModalEvents() {
    const modal = document.getElementById("reviewModal");
    if (!modal) return;

    const form = modal.querySelector("form#reviewForm");
    if (!form) return;

    // cancel 버튼
    const btnCancel = modal.querySelector("[data-action='close-review']");
    if (btnCancel) btnCancel.addEventListener("click", closeReviewModal);

    // 별점 표시
    const scoreEl = modal.querySelector("#ratingScore");
    const ratingRadios = modal.querySelectorAll('input[name="rating"]');
    ratingRadios.forEach((radio) => {
      radio.addEventListener("change", (e) => {
        if (scoreEl) scoreEl.textContent = e.target.value + ".0";
      });
    });

    // 글자수
    const ta = modal.querySelector("#reviewContents");
    const cnt = modal.querySelector("#charCurrent");
    if (ta && cnt) {
      cnt.textContent = String(ta.value.length);
      ta.addEventListener("input", () => {
        cnt.textContent = String(ta.value.length);
      });
    }

    // submit 중복 바인딩 방지: 이미 바인딩되어 있으면 skip
    if (form.dataset.bound === "1") return;
    form.dataset.bound = "1";

    form.addEventListener("submit", async (e) => {
      e.preventDefault();

      const checked = modal.querySelector('input[name="rating"]:checked');
      if (!checked) {
        alert("별점을 선택해주세요.");
        return;
      }

      const ratingVal = parseInt(checked.value, 10);
      if (Number.isNaN(ratingVal) || ratingVal < 1 || ratingVal > 5) {
        alert("별점은 1~5점만 가능합니다.");
        return;
      }

      if (ta && ta.value.length > 100) {
        alert("리뷰 내용은 100자 이내로 작성해주세요.");
        return;
      }

      const submitBtn = modal.querySelector("button[type='submit']");
      if (submitBtn) submitBtn.disabled = true;

      try {
        const res = await fetch(form.action, {
          method: "POST",
          headers: { "X-Requested-With": "XMLHttpRequest" },
          body: new FormData(form),
        });

        // JSON 아닌 경우도 대비
        const ct = (res.headers.get("content-type") || "").toLowerCase();
        if (!ct.includes("application/json")) {
          alert("서버 응답 형식이 올바르지 않습니다.");
          return;
        }

        const data = await res.json();

        if (!data || !data.ok) {
          alert(data && data.msg ? data.msg : "등록에 실패했습니다.");
          return;
        }

        alert(data.msg || "리뷰가 등록되었습니다.");

        const lastBtnId = modal.dataset.lastBtnId;
        if (lastBtnId) {
          const b = document.getElementById(lastBtnId);
          if (b) {
            b.textContent = "작성완료";
            b.disabled = true;
            b.classList.add("done");
          }
        }

        closeReviewModal();
      } catch (err) {
        console.error(err);
        alert("처리 중 오류가 발생했습니다.");
      } finally {
        if (submitBtn) submitBtn.disabled = false;
      }
    });
  }

  // 전역에서 onclick="..." 으로 호출 중이면 window에 노출
  window.toggleOrderDetails = toggleOrderDetails;
  window.openTrackingPopup = openTrackingPopup;
  window.openReviewModal = openReviewModal;
  window.closeReviewModal = closeReviewModal;

  // ctxPath를 JSP에서 주입하는 방식도 지원(선택)
  // 예: <script>window.__CTX_PATH__ = "<%=request.getContextPath()%>";</script>
})();
