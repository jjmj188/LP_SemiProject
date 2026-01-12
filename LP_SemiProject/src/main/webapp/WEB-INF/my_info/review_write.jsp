<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>


<style>
  .review-wrap{
   padding:0 6px; 
   }
  .product-box{ 
  display:flex; 
  gap:14px; 
  padding:16px 0; 
  border-top:1px solid #eee; 
  border-bottom:1px solid #eee; 
  align-items:center; 
  background:#fff; 
  }
  .product-img{
   width:100px; 
   height:100px; 
   border:1px solid #e6e6e6; 
   background:#f5f5f5; 
   flex:0 0 auto; 
   }
  .product-img img{
   width:100%;
    height:100%;
     object-fit:cover; 
     }
  .product-meta{
   flex:1; 
   }
  .product-name{
   margin:0 0 8px;
    font-size:15px; 
    font-weight:700; 
    }
  .product-sub{ 
  display:flex; 
  gap:12px; 
  font-size:13px; 
  color:#444; 
  }
  .badge{ 
  display:inline-flex; 
  align-items:center; 
  gap:6px; 
  padding:6px 10px; 
  border-radius:999px; 
  background:#fafafa; 
  }

  .rating-row{ 
  display:flex; 
  justify-content:space-between; 
  align-items:center; 
  margin-bottom:14px; 
  }

  #reviewForm fieldset{ 
  border:0; 
  margin:0; 
  padding:0; 
  direction:rtl; 
  }
  #reviewForm input[type=radio]{ 
  display:none;
   }
  #reviewForm label i{ 
  font-size:32px; 
  color:#e0e0e0; 
  cursor:pointer; 
  }
  #reviewForm label:hover i, #reviewForm label:hover ~ label i{
   color:rgba(250,208,0,.99);
    }
  #reviewForm input[type=radio]:checked ~ label i{ 
  color:rgba(250,208,0,.99); 
  }

  .rating-text{ 
  font-size:15px; 
  min-width:90px; 
  text-align:right; 
  }
  #ratingScore{ 
  font-weight:800; 
  font-size:16px; 
  }

  #reviewContents{ 
  width:100%; 
  height:150px; 
  padding:12px; 
  border:1.5px solid #d3d3d3; 
  border-radius:8px; 
  resize:none; 
  font-size:15px; 
  }
  .review-textarea-wrap{ 
  position:relative; 
  }
  .char-count{ 
  position:absolute; 
  right:10px; 
  bottom:8px; 
  font-size:12px; 
  color:#666; 
  }

  .btn-row{ 
  display:flex; 
  justify-content:flex-end; 
  gap:10px; 
  margin-top:14px;
   }
  .btn{ 
  padding:10px 16px; 
  border-radius:10px; 
  font-size:14px; 
  cursor:pointer; 
  }
  .btn-cancel{ 
  background:#fff; 
  border:1px solid #cfcfcf; 
  }
  .btn-submit{ 
  background:#222; 
  color:#fff; 
  border:1px solid #222; 
  }

  .review-title{ 
  margin:0 0 14px; 
  font-size:18px; 
  font-weight:700; 
  }
</style>

<div class="review-wrap">

  <h2 class="review-title">리뷰 작성</h2>

  <div class="product-box">
    <div class="product-img">
      <c:choose>
        <c:when test="${not empty prdImg}">
          <img src="<%= ctxPath %>${prdImg}" alt="상품 이미지">
        </c:when>
        <c:otherwise>
          <img src="<%=ctxPath%>/images/sample_lp.png" alt="상품 이미지">
        </c:otherwise>
      </c:choose>
    </div>

    <div class="product-meta">
      <p class="product-name"><c:out value="${prdName}" default="상품명" /></p>
      <div class="product-sub">
        <span class="badge">
          가격 : <fmt:formatNumber value="${price}" pattern="#,###" />원
        </span>
      </div>
    </div>
  </div>

  <form id="reviewForm" method="post" action="<%= ctxPath %>/my_info/review_write_end.lp">
    <input type="hidden" name="orderno" value="${orderno}" />
    <input type="hidden" name="productno" value="${productno}" />

    <h3>구매하신 상품은 만족하시나요?</h3>
    <p>별점으로 후기를 남겨주세요</p>

    <div class="rating-row">
      <fieldset>
        <input type="radio" name="rating" value="5" id="rate1">
        <label for="rate1"><i class="fa-solid fa-star"></i></label>

        <input type="radio" name="rating" value="4" id="rate2">
        <label for="rate2"><i class="fa-solid fa-star"></i></label>

        <input type="radio" name="rating" value="3" id="rate3">
        <label for="rate3"><i class="fa-solid fa-star"></i></label>

        <input type="radio" name="rating" value="2" id="rate4">
        <label for="rate4"><i class="fa-solid fa-star"></i></label>

        <input type="radio" name="rating" value="1" id="rate5">
        <label for="rate5"><i class="fa-solid fa-star"></i></label>
      </fieldset>

      <span class="rating-text">
        <span id="ratingScore">0.0</span> / 5.0
      </span>
    </div>

    <div class="review-textarea-wrap">
      <textarea id="reviewContents" name="reviewcontent" maxlength="100"
        placeholder="리뷰 내용을 작성해주세요"></textarea>
      <div class="char-count"><span id="charCurrent">0</span>/100</div>
    </div>

    <div class="btn-row">
      <button type="button" class="btn btn-cancel" data-action="close-review">취소하기</button>
      <button type="submit" class="btn btn-submit">등록하기</button>
    </div>
  </form>
</div>
