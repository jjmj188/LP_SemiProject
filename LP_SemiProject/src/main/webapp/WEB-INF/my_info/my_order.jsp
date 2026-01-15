<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>
<%-- [추가] 문자열 처리를 위한 fn 라이브러리 --%>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions"%>

<link rel="stylesheet" href="<%=ctxPath%>/css/my_info/mypage_layout.css">
<link rel="stylesheet"
	href="<%=ctxPath%>/css/my_info/my_inquiry_list.css">
<link rel="stylesheet" href="<%=ctxPath%>/css/my_info/my_order.css">
<link rel="stylesheet"
	href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">

<style>
.price-row {
	display: flex;
	align-items: baseline;
	gap: 10px;
	flex-wrap: wrap;
}

.price-original {
	color: #9aa0a6;
	text-decoration: line-through;
	text-decoration-thickness: 1px;
	text-decoration-color: #9aa0a6;
}

.price-discounted {
	font-weight: 700;
}

/* ===== 리뷰 모달 ===== */
.review-modal {
	position: fixed;
	inset: 0;
	z-index: 9999;
	display: none;
}

.review-modal.open {
	display: block;
}

.review-modal .backdrop {
	position: absolute;
	inset: 0;
	background: rgba(0, 0, 0, .45);
}

.review-modal .panel {
	position: relative;
	width: min(640px, calc(100vw - 24px));
	max-height: calc(100vh - 24px);
	overflow: auto;
	margin: 12px auto;
	background: #fff;
	border-radius: 14px;
	box-shadow: 0 12px 34px rgba(0, 0, 0, .25);
}

.review-modal .panel-head {
	position: sticky;
	top: 0;
	background: #fff;
	border-bottom: 1px solid #eee;
	padding: 12px 14px;
	display: flex;
	align-items: center;
	justify-content: space-between;
}

.review-modal .panel-title {
	margin: 0;
	font-size: 16px;
	font-weight: 700;
}

.review-modal .btn-x {
	border: 0;
	background: transparent;
	cursor: pointer;
	font-size: 22px;
	line-height: 1;
}

.review-modal .panel-body {
	padding: 12px 14px 18px;
}

.review-modal .loading {
	padding: 22px 0;
	text-align: center;
	color: #666;
}


    /* PAGE BAR 스타일 */
    .pagebar {
      margin-top: 40px;
      display: flex;
      justify-content: center;
      align-items: center;
      gap: 6px;
    }

    .pagebar button {
      min-width: 36px;
      height: 36px;
      padding: 0 10px;
      margin: 0 3px;
      border: 1px solid #ddd;
      background: #fff;
      font-size: 14px;
      color: #222;
      cursor: pointer;
      transition: all 0.2s ease;
    }

    .pagebar .page-num {
      font-weight: 500;
    }

    .pagebar .page-num.active {
      background: #222;
      color: #fff;
      border-color: #222;
      cursor: default;
    }

    .pagebar button:not(.active):hover {
      background: #222;
      color: #fff;
      border-color: #222;
    }
</style>


<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<main class="mypage-wrapper">
	<div class="mypage-container">

		<aside class="mypage-menu">
			<h3>마이페이지</h3>
			<a href="<%=ctxPath%>/my_info/my_info.lp">프로필 수정</a> <a
				href="<%=ctxPath%>/my_info/my_inquiry.lp">문의내역</a> <a
				href="<%=ctxPath%>/my_info/my_wish.lp">찜내역</a> <a
				href="<%=ctxPath%>/my_info/my_order.lp" class="active">구매내역</a> <a
				href="<%=ctxPath%>/my_info/my_taste.lp">취향선택</a>
		</aside>

		<section class="mypage-content">
			<h2>구매내역</h2>

			<div class="order-list">

				<c:if test="${empty orderList}">
					<div style="padding: 20px;">구매내역이 없습니다.</div>
				</c:if>

				<c:forEach var="o" items="${orderList}">

					<fmt:parseNumber var="totalpriceNum"
						value="${empty o.totalprice ? 0 : o.totalprice}"
						integerOnly="true" />
					<fmt:parseNumber var="usepointNum"
						value="${empty o.usepoint ? 0 : o.usepoint}" integerOnly="true" />

					<c:set var="pointDiscountWon" value="${usepointNum * 10}" />
					<c:set var="discountedPrice"
						value="${totalpriceNum - pointDiscountWon}" />

					<div class="order-card">
						<div class="order-summary">

							<div class="order-product">
								
								<%-- [수정] 대표 이미지 경로 정규화 --%>
                                <c:set var="repImg" value="${o.repProductimg}" />
                                <c:if test="${fn:contains(repImg, 'images')}">
                                    <c:set var="repImg" value="${fn:replace(repImg, '/images/productimg/', '')}" />
                                    <c:set var="repImg" value="${fn:replace(repImg, 'images/productimg/', '')}" />
                                </c:if>
                                
								<img src="<%=ctxPath%>/images/productimg/${repImg}" alt="대표 상품">
								
								<div class="product-info">

									<div class="product-name">
										<p class="name">상품명 : ${o.repProductname}</p>
										<c:if test="${o.moreCount > 0}">
											<span class="more-count">외 ${o.moreCount}건</span>
										</c:if>
									</div>

									<p class="meta">총 수량 : ${o.totalQty}개</p>

									<p class="price">
										<span class="price-row">총 가격 : <c:choose>
												<c:when test="${usepointNum > 0}">
													<span class="price-original"> <fmt:formatNumber
															value="${totalpriceNum}" pattern="#,###" />원
													</span>
													<span class="price-discounted"> <fmt:formatNumber
															value="${discountedPrice}" pattern="#,###" />원
													</span>
												</c:when>
												<c:otherwise>
													<span class="price-discounted"> <fmt:formatNumber
															value="${totalpriceNum}" pattern="#,###" />원
													</span>
												</c:otherwise>
											</c:choose>
										</span>
									</p>

								</div>
							</div>

							<div class="order-point">
								<span>적립포인트: <fmt:formatNumber value="${o.totalpoint}"
										pattern="#,###" />p
								</span>
								<button class="btn-toggle" type="button"
									onclick="toggleOrderDetails(this)">펼치기 ▼</button>
							</div>

							<div class="order-status">
								<p class="date">${o.orderdate}</p>
								<p class="status-text">${o.deliverystatus}</p>

								<button class="btn-toggle" type="button"
									data-orderno="${o.orderno}" onclick="openTrackingModal(this)">
									배송지 & 송장번호</button>

							</div>

						</div>

						<div class="order-details" aria-hidden="true">
							<div class="detail-list">

								<c:forEach var="d" items="${o.orderDetailList}">
									<div class="detail-item">
										
										<%-- [수정] 상세 이미지 경로 정규화 --%>
                                        <c:set var="detailImg" value="${d.productimg}" />
                                        <c:if test="${fn:contains(detailImg, 'images')}">
                                            <c:set var="detailImg" value="${fn:replace(detailImg, '/images/productimg/', '')}" />
                                            <c:set var="detailImg" value="${fn:replace(detailImg, 'images/productimg/', '')}" />
                                        </c:if>
										
										<img src="<%=ctxPath%>/images/productimg/${detailImg}" alt="상품">
										
										<div class="detail-info">
											<p class="d-name">${d.productname}</p>
											<p class="d-sub">수량: ${d.qty}개</p>
										</div>

										<div class="detail-actions">
											<div class="detail-price">
												<fmt:formatNumber value="${d.lineprice}" pattern="#,###" />
												원
											</div>

											<c:if test="${o.deliverystatus eq '배송완료'}">
												<c:choose>
													<c:when test="${d.hasReview == 1}">
														<button type="button" class="btn-review-done">작성완료</button>
													</c:when>
													<c:otherwise>
														<button type="button" class="btn-review"
															data-orderno="${o.orderno}"
															data-productno="${d.productno}"
															onclick="openReviewModal(this)">리뷰쓰기</button>
													</c:otherwise>
												</c:choose>
											</c:if>

										</div>
									</div>
								</c:forEach>

							</div>
						</div>
					</div>
				</c:forEach>

				<div class="pagebar">
				    <ul class="pagination"
				        style="margin: 0; list-style: none; display: flex; justify-content: center; padding: 0;">
				    ${requestScope.pageBar}
				    </ul>
				</div>


			</div>
		</section>
	</div>
</main>

<div id="reviewModal" class="review-modal" aria-hidden="true">
	<div class="backdrop" onclick="closeReviewModal()"></div>

	<div class="panel" role="dialog" aria-modal="true" aria-label="리뷰 작성">
		<div class="panel-head">
			<p class="panel-title">리뷰 작성</p>
			<button type="button" class="btn-x" onclick="closeReviewModal()"
				aria-label="닫기">×</button>
		</div>
		<div class="panel-body">
			<div class="loading">불러오는 중...</div>
		</div>
	</div>
</div>

<div id="trackingModal" class="review-modal" aria-hidden="true">
	<div class="backdrop" onclick="closeTrackingModal()"></div>

	<div class="panel" role="dialog" aria-modal="true"
		aria-label="배송지 & 송장번호">
		<div class="panel-head">
			<p class="panel-title">배송지 & 송장번호</p>
			<button type="button" class="btn-x" onclick="closeTrackingModal()"
				aria-label="닫기">×</button>
		</div>
		<div class="panel-body">
			<div class="loading">불러오는 중...</div>
		</div>
	</div>
</div>


<jsp:include page="/WEB-INF/footer1.jsp" />

<script type="text/javascript">
"use strict";
//페이지 이동 함수
function goPage(pageNo) {
    const currentURL = window.location.href;
    const newURL = new URL(currentURL);
    newURL.searchParams.set('currentShowPageNo', pageNo); // currentShowPageNo를 페이지 번호로 업데이트
    window.location.href = newURL.toString(); // 페이지 리로드
}

(function () {

  // ✅ JSP ctxPath를 JS로 직접 주입
  const ctxPath = "<%= ctxPath %>";

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

  // ===== 배송지&송장 모달 =====
  function closeTrackingModal() {
     const modal = document.getElementById("trackingModal");
    if (!modal) return;

    modal.classList.remove("open");
    modal.setAttribute("aria-hidden", "true");
    modal.dataset.lastBtnId = "";

    const body = modal.querySelector(".panel-body");
    if (body) body.innerHTML = '<div class="loading">불러오는 중...</div>';
  }

  async function openTrackingModal(btn) {
    if (!btn) return;
    const orderno = btn.dataset.orderno;
    if (!orderno) {
      alert("주문번호를 찾을 수 없습니다.");
      return;
    }

    if (!btn.id) btn.id = "btnTracking_" + orderno;
    const url =
      ctxPath +
      "/my_info/tracking_popup.lp?orderno=" +
      encodeURIComponent(orderno);
    const modal = document.getElementById("trackingModal");
    if (!modal) {
      alert("배송 모달 요소(#trackingModal)를 찾을 수 없습니다.");
      return;
    }

    const body = modal.querySelector(".panel-body");
    if (!body) {
      alert("배송 모달 본문(.panel-body)을 찾을 수 없습니다.");
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
        alert(data && data.msg ? data.msg : "배송 정보를 불러올 수 없습니다.");
        closeTrackingModal();
        return;
      }

      const html = await res.text();
      body.innerHTML = html;
      // 모달 내부 닫기 버튼(있다면) 바인딩
      const closeBtn = modal.querySelector("[data-action='close-tracking']");
      if (closeBtn) closeBtn.addEventListener("click", closeTrackingModal);
    } catch (e) {
      console.error(e);
      alert("배송 정보를 불러오지 못했습니다.");
      closeTrackingModal();
    }
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

    if (btn.disabled || btn.classList.contains("done")) return;
    const orderno = btn.dataset.orderno;
    const productno = btn.dataset.productno;

    if (!orderno || !productno) {
      alert("리뷰 정보를 열 수 없습니다. (주문/상품 식별값 누락)");
      return;
    }

    if (!btn.id) btn.id = "btnReview_" + orderno + "_" + productno;
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

    // submit 중복 바인딩 방지
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
          headers: { 
          "X-Requested-With": "XMLHttpRequest" },
          body: new FormData(form),
        });

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

  window.toggleOrderDetails = toggleOrderDetails;
  window.openTrackingModal = openTrackingModal;
  window.closeTrackingModal = closeTrackingModal;
  window.openReviewModal = openReviewModal;
  window.closeReviewModal = closeReviewModal;

})();
</script>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<%-- <script src="<%=ctxPath%>/js/my_info/my_order.js"></script> --%>