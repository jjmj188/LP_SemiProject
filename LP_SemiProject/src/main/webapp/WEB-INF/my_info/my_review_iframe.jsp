<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>

<%
    String ctxPath = request.getContextPath();
%>

<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">

<style>

    /* 1. 바디와 전체 wrap의 여백을 완전히 0으로 제거 */
    body { 
        margin: 0; padding: 0; 
        font-family: 'Pretendard', sans-serif; 
        background: #fff; 
        overflow-x: hidden; 
    }
    
    .review-wrap { 
        padding: 0; /* 양옆 여백 아예 제거 */
        width: 100%;
    }
    
    .review-item {
        padding: 15px 5px; /* 위아래는 유지, 양옆은 5px만 최소로 */
        border-bottom: 1px solid #f0f0f0; 
        cursor: pointer;
        transition: background 0.2s;
        box-sizing: border-box; /* 패딩이 너비에 영향 안 주게 */
    }
    .review-item:last-child { border-bottom: none; }
    .review-item:hover { background: #fafafa; }

    /* 2. 상품명 라인: 공간을 100% 사용 */
    .top-row { 
        display: flex; 
        justify-content: space-between; 
        align-items: center; 
        margin-bottom: 6px;
        gap: 10px;
    }
    
    .product-name {
        font-size: 14px; 
        font-weight: 700; 
        color: #222;
        flex: 1; /* 별점 빼고 남은 공간 다 차지 */
        white-space: nowrap; 
        overflow: hidden; 
        text-overflow: ellipsis;
    }

    .stars-simple {
        display: flex;
        align-items: center;
        gap: 4px;
        color: #fad000;
        font-size: 13px;
        flex-shrink: 0;
    }
    
    .score-num { color: #333; font-weight: 700; }

    .review-text {
        font-size: 13px; 
        color: #666;
        white-space: nowrap; 
        overflow: hidden; 
        text-overflow: ellipsis;
        display: block;
        width: 100%;
    }

    .empty-msg { text-align: center; padding: 50px 0; font-size: 14px; color: #999; }

	    
	    .review-item {
	  padding: 15px 10px; /* 위아래 여백을 줘서 답답하지 않게 */
	  border-bottom: 1px solid #f0f0f0; /* 🔥 연한 회색 구분선 추가 */
	  cursor: pointer;
	  transition: background 0.2s;
	}
	
	.review-item:last-child {
	  border-bottom: none; /* 마지막 리뷰 아래에는 선이 없도록 설정 */
	}
	
	.review-item:hover {
	  background: #fafafa; /* 마우스 올렸을 때 반응 */
	}
	
			.stars-simple {
		    display: flex;
		    align-items: center;
		    gap: 4px;      /* 별과 숫자 사이 간격 */
		    color: #fad000; /* 별 색상 (노란색) */
		    font-size: 13px;
		}
		
		.score-num {
		    color: #333;   /* 숫자 색상 (진한 회색) */
		    font-weight: 700;
		}
		
		.top-row {
		    display: flex;
		    justify-content: space-between; /* 상품명은 왼쪽, 별점은 오른쪽 끝으로 */
		    align-items: center;
		    margin-bottom: 6px;
		}
</style>
</head>

<body>

<div class="review-wrap">

    <c:if test="${not empty reviewList}">
        <c:forEach var="review" items="${reviewList}">

            <div class="review-item" onclick="parent.openReviewModal('${review.reviewno}')">

                <div class="top-row">
                    <div class="product-name">
                        ${review.productname}
                    </div>

                    <div class="stars-simple">
                        <i class="fa-solid fa-star"></i>
                        <span class="score-num">${review.rating}.0</span>
                    </div>
                </div>

                <div class="review-text">
                    <c:choose>
                        <c:when test="${fn:length(review.reviewcontent) > 40}">
                            ${fn:substring(review.reviewcontent, 0, 40)}…
                        </c:when>
                        <c:otherwise>
                            ${review.reviewcontent}
                        </c:otherwise>
                    </c:choose>
                </div>

            </div> 
        </c:forEach>
    </c:if>

    <c:if test="${empty reviewList}">
        <div class="empty-msg">
            <i class="fa-regular fa-face-meh" style="font-size: 24px; display: block; margin-bottom: 10px;"></i>
            작성된 리뷰가 없습니다.
        </div>
    </c:if>

</div>

</body>
</html>