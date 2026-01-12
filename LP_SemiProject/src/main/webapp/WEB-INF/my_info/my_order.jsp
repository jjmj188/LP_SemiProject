<%@ page language="java" contentType="text/html; charset=UTF-8"
	pageEncoding="UTF-8"%>
<%
String ctxPath = request.getContextPath();
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt"%>

<link rel="stylesheet"
	href="<%=ctxPath%>/css/my_info/mypage_layout.css">
<link rel="stylesheet"
	href="<%=ctxPath%>/css/my_info/my_inquiry_list.css">
<link rel="stylesheet" href="<%=ctxPath%>/css/my_info/my_order.css">

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
								<img src="<%= ctxPath%>${o.repProductimg}" alt="대표 상품">
								<div class="product-info">

									<div class="product-name">
										<p class="name">상품명 : ${o.repProductname}</p>
										<c:if test="${o.moreCount > 0}">
											<span class="more-count">외 ${o.moreCount}건</span>
										</c:if>
									</div>

									<p class="meta">총 수량 : ${o.totalQty}개</p>

									<p class="price">

										<span class="price-row"> 총 가격 : <c:choose>
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
									data-orderno="${o.orderno}" onclick="openTrackingPopup(this)">
									배송지 & 송장번호</button>
							</div>

						</div>

						<div class="order-details" aria-hidden="true">
							<div class="detail-list">

								<c:forEach var="d" items="${o.orderDetailList}">
									<div class="detail-item">
										<img src="<%= ctxPath%>${d.productimg}" alt="상품">
										<div class="detail-info">
											<p class="d-name">${d.productname}</p>
											<p class="d-sub">수량: ${d.qty}개</p>
										</div>

										<div class="detail-actions">
											<div class="detail-price">
												<fmt:formatNumber value="${d.lineprice}" pattern="#,###" />
												원
											</div>

											<button class="btn-review" type="button"
												data-orderno="${o.orderno}" data-productno="${d.productno}"
												onclick="openReviewPopup(this)">리뷰쓰기
											</button>


										</div>
									</div>
								</c:forEach>

							</div>
						</div>
					</div>
				</c:forEach>

				<div class="pagebar">
					<ul class="pagination" style="margin: 0;">
						${requestScope.pageBar}
					</ul>
				</div>

			</div>
		</section>
	</div>
</main>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%=ctxPath%>/js/my_info/my_order.js"></script>
