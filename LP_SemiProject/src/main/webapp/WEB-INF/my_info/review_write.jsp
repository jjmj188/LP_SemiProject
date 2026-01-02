<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <!-- Font Awesome 6 Icons -->
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">

  <title>리뷰 작성</title>

  <style>
    /* ====== product info ====== */
    .product-box{
      display:flex;
      gap:14px;
      padding:16px 18px;
      border-top:1px solid #eee;
      border-bottom:1px solid #eee;
      align-items:center;
      background:#fff;
    }

    .product-img{
      width:100px;
      height:100px;
      overflow:hidden;
      border:1px solid #e6e6e6;
      flex: 0 0 auto;
      background:#f5f5f5;
    }

    .product-img img{
      width:100%;
      height:100%;
      object-fit:cover;
      display:block;
    }

    .product-meta{
      flex:1;
      min-width:0;
    }

    .product-name{
      margin:0 0 8px;
      font-size:15px;
      font-weight:700;
      line-height:1.25;
      white-space:nowrap;
      overflow:hidden;
      text-overflow:ellipsis;
    }

    .product-sub{
      display:flex;
      flex-wrap:wrap;
      gap:10px 14px;
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

    .badge i{ color:#666; }

    /* ====== form ====== */
    form#myform{
      padding:18px;
    }

    /* ===== 별점 정렬 ===== */
    .rating-row{
      display:flex;
      align-items:center;
      justify-content:space-between;
      gap:16px;
      margin-bottom:14px;
    }

    /* RTL 별점 */
    #myform fieldset{
      margin:0;
      padding:0;
      border:0;
      display:inline-block;
      direction:rtl;
    }

    #myform input[type=radio]{
      display:none;
    }

    /* 별 기본 */
    #myform label i{
      font-size:32px;
      color:#e0e0e0;
      cursor:pointer;
      transition:color .2s ease, transform .15s ease;
    }

    /* hover */
    #myform label:hover i,
    #myform label:hover ~ label i{
      color: rgba(250, 208, 0, 0.99);
    }

    /* 선택 */
    #myform input[type=radio]:checked ~ label i{
      color: rgba(250, 208, 0, 0.99);
    }

    /* ✅ 점수 텍스트 (전역 strong 스타일 영향 차단) */
    .rating-text{
      display:inline-flex;          /* 전역 display 깨짐 방지 */
      align-items:baseline;
      gap:6px;
      font-size:15px;
      color:#222 !important;        /* 전역 색상 덮어쓰기 */
      min-width:90px;
      justify-content:flex-end;
      text-align:right;
      line-height:1;
      white-space:nowrap;
    }
    /* strong 대신 id로 표시하니까 strong 전역 영향에서도 안전 */
    #ratingScore{
      display:inline-block !important;
      font-weight:800;
      font-size:16px;
      color:#111 !important;
      letter-spacing:0.2px;
    }

    /* textarea */
    #reviewContents{
      width:100%;
      height:150px;
      padding:12px;
      box-sizing:border-box;
      border:1.5px solid #d3d3d3;
      border-radius:8px;
      font-size:15px;
      resize:none;
    }
    #reviewContents:focus{
      border-color:#222;
      outline:none;
    }

    /* textarea 감싸는 영역 */
    .review-textarea-wrap{
      position:relative;
    }

    /* 글자 수 표시 */
    .char-count{
      position:absolute;
      right:10px;
      bottom:8px;
      font-size:12px;
      color:#666;
      pointer-events:none;
    }

    /* ====== buttons ====== */
    .btn-row{
      display:flex;
      justify-content:flex-end;
      gap:10px;
      margin-top:14px;
    }

    .btn{
      padding:10px 16px;
      border-radius:10px;
      border:1px solid #222;
      font-size:14px;
      cursor:pointer;
      transition: background .2s ease, color .2s ease;
    }

    .btn-cancel{
      background:#fff;
      color:#222;
      border-color:#cfcfcf;
    }
    .btn-cancel:hover{ background:#f3f3f3; }

    .btn-submit{
      background:#222;
      color:#fff;
    }
    .btn-submit:hover{ background:#000; }

    /* (원래 코드에 있던 제목 영역 최소 스타일) */
    .review-head{
      padding:18px 18px 0;
    }
    .review-title{
      margin:0 0 14px;
      font-size:18px;
      font-weight:700;
    }
  </style>
</head>

<body>
  <div class="review-wrap">
    <div class="review-head">
      <h2 class="review-title">리뷰 작성</h2>
    </div>

    <!-- 상품 정보 -->
    <div class="product-box">
      <div class="product-img">
        <img src="../images/sample_lp.png" alt="상품 이미지">
      </div>

      <div class="product-meta">
        <p class="product-name">ROSÉ - Sample LP (Limited)</p>
        <div class="product-sub">
          <span class="badge"><i class="fa-solid fa-won-sign"></i> 가격: 32,000원</span>
        </div>
      </div>
    </div>

    <!-- 리뷰 폼 -->
    <form name="myform" id="myform" method="post">
      <h3>구매하신 상품은 만족하시나요?</h3>
      <p>별점으로 후기를 남겨주세요</p>

      <div class="rating-row">
        <fieldset>
          <input type="radio" name="reviewStar" value="5" id="rate1">
          <label for="rate1"><i class="fa-solid fa-star"></i></label>

          <input type="radio" name="reviewStar" value="4" id="rate2">
          <label for="rate2"><i class="fa-solid fa-star"></i></label>

          <input type="radio" name="reviewStar" value="3" id="rate3">
          <label for="rate3"><i class="fa-solid fa-star"></i></label>

          <input type="radio" name="reviewStar" value="2" id="rate4">
          <label for="rate4"><i class="fa-solid fa-star"></i></label>

          <input type="radio" name="reviewStar" value="1" id="rate5">
          <label for="rate5"><i class="fa-solid fa-star"></i></label>
        </fieldset>

        <!-- ✅ strong 제거 + id로 표시 -->
        <span class="rating-text">
          <span id="ratingScore">0.0</span>
          <span>/ 5.0</span>
        </span>
      </div>

      <!-- 리뷰 내용 -->
      <div class="review-textarea-wrap">
        <textarea id="reviewContents" name="reviewContents" maxlength="100"
          placeholder="리뷰 내용을 작성해주세요"></textarea>

        <div class="char-count">
          <span id="charCurrent">0</span>/100
        </div>
      </div>

      <div class="btn-row">
        <button type="button" class="btn btn-cancel" onclick="history.back()">취소하기</button>
        <button type="submit" class="btn btn-submit">등록하기</button>
      </div>
    </form>
  </div>

  <script>
    document.addEventListener('DOMContentLoaded', function () {
      const scoreEl = document.getElementById('ratingScore');

      document.querySelectorAll('#myform input[name="reviewStar"]').forEach(radio => {
        radio.addEventListener('change', function () {
          scoreEl.textContent = this.value + '.0';
        });
      });

      const textarea = document.getElementById('reviewContents');
      const counter = document.getElementById('charCurrent');

      textarea.addEventListener('input', function () {
        counter.textContent = this.value.length;
      });
    });
  </script>
</body>
</html>
