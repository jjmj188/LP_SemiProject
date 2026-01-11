<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<% String ctxPath = request.getContextPath(); %>

<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">

  <title>리뷰 상세보기</title>

  <style>
    /* 1. 폰트 설정: 가독성 좋은 시스템 폰트 조합으로 일치시킴 */
    body { 
      margin: 0; padding: 0; 
      font-family: 'Pretendard', -apple-system, BlinkMacSystemFont, "Malgun Gothic", "맑은 고딕", sans-serif; 
      background: #fff; color: #333;
      line-height: 1.5;
    }
    
    .review-wrap { padding-bottom: 20px; }
    
    /* 제목 부분 폰트 스타일 조정 */
    .review-head { padding: 22px 18px 15px; }
    .review-title { margin: 0; font-size: 17px; font-weight: 700; color: #111; letter-spacing: -0.3px; }

    /* 2. 상품 박스 레이아웃: 가로 정렬(Flex) 유지 */
    .product-box { 
      display: flex !important; 
      gap: 16px; 
      padding: 18px; 
      border-top: 1px solid #f2f2f2; 
      border-bottom: 1px solid #f2f2f2; 
      align-items: center; 
      background: #fff; 
    }

    /* 이미지 박스 크기 고정 및 정렬 */
    .product-img { 
      width: 90px; height: 90px; 
      overflow: hidden; 
      border: 1px solid #eee; 
      border-radius: 8px; 
      flex: 0 0 auto; /* 크기 고정 */
      background: #f9f9f9; 
    }
    .product-img img { width: 100%; height: 100%; object-fit: cover; display: block; }
    
    /* 텍스트 영역 */
    .product-meta { flex: 1; min-width: 0; }
    .product-name { 
      margin: 0 0 8px; 
      font-size: 15px; 
      font-weight: 700; 
      color: #222; 
      line-height: 1.4;
      display: -webkit-box;
      -webkit-line-clamp: 2;
      -webkit-box-orient: vertical;
      overflow: hidden;
    }
    
    .product-sub { display: flex; flex-direction: column; gap: 5px; font-size: 13px; color: #777; }
    .info-item { display: inline-flex; align-items: center; gap: 6px; }
    .info-item i { color: #aaa; font-size: 12px; }

    /* 3. 본문 내용 스타일 */
    .content-body { padding: 20px 18px; }
    .content-subtitle { margin-bottom: 14px; font-size: 14px; font-weight: 500; color: #666; }
    
    .rating-row { display: flex; align-items: center; justify-content: space-between; margin-bottom: 16px; }
    
    /* 별점 스타일 */
    .stars-view { color: #fad000; font-size: 24px; display: flex; gap: 2px; }
    .stars-view i.empty { color: #eee; }

    .rating-text { font-size: 14px; color: #999; }
    #ratingScore { font-weight: 700; font-size: 15px; color: #222; }

    /* 리뷰 텍스트 영역 */
    #reviewContents {
      width: 100%; height: 140px; padding: 15px; box-sizing: border-box;
      border: 1px solid #e8e8e8; border-radius: 10px; font-size: 14px; line-height: 1.6; resize: none;
      background: #fdfdfd; color: #444; outline: none;
    }

    /* 4. 버튼 스타일 */
    .btn-row { display: flex; justify-content: flex-end; gap: 10px; margin-top: 20px; padding: 0 18px; }
    .btn { padding: 12px 22px; border-radius: 8px; font-size: 14px; font-weight: 600; cursor: pointer; border: none; transition: 0.2s; }
    .btn-cancel { background: #f0f0f0; color: #666; }
    .btn-submit { background: #222; color: #fff; }
    .btn:hover { opacity: 0.8; }
  </style>
</head>

<body>
  <div class="review-wrap">
    <div class="review-head">
      <h2 class="review-title">내가 쓴 리뷰 상세</h2>
    </div>

    <div class="product-box">
      <div class="product-img">
        <img src="<%= ctxPath %>${rdto.productimg}" 
             onerror="this.src='<%= ctxPath %>/images/noimage.png'" alt="상품 이미지">
      </div>

      <div class="product-meta">
        <p class="product-name">${rdto.productname}</p>
        <div class="product-sub">
          <span class="info-item">
            <i class="fa-solid fa-calendar-days"></i> 작성일: ${rdto.writedate}
          </span>
        </div>
      </div>
    </div>

    <div class="content-body">
      <p class="content-subtitle">작성하신 리뷰 내용입니다.</p>

      <div class="rating-row">
        <div class="stars-view">
          <c:forEach begin="1" end="5" var="i">
            <c:choose>
              <c:when test="${i <= rdto.rating}">
                <i class="fa-solid fa-star"></i>
              </c:when>
              <c:otherwise>
                <i class="fa-solid fa-star empty"></i>
              </c:otherwise>
            </c:choose>
          </c:forEach>
        </div>

        <span class="rating-text">
          <span id="ratingScore">${rdto.rating}.0</span> / 5.0
        </span>
      </div>

      <textarea id="reviewContents" readonly>${rdto.reviewcontent}</textarea>
    </div>

    <div class="btn-row">
      <button type="button" class="btn btn-cancel" onclick="parent.closeReviewModal()">닫기</button>
      <button type="button" class="btn btn-submit" onclick="goDelete('${rdto.reviewno}')">삭제하기</button>
    </div>
  </div>

  <script>
    function goDelete(reviewno) {
        if(confirm("정말 이 리뷰를 삭제하시겠습니까?\n삭제 후에는 복구할 수 없습니다.")) {
            parent.location.href = "<%= ctxPath %>/my_info/review_delete.lp?reviewno=" + reviewno;
        }
    }
  </script>
</body>
</html>