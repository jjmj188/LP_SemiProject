<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>취향 선택</title>

  <!--<link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">-->
  <link rel="stylesheet" href="../css/member/taste_check.css">
</head>

<body class="bg-light">

<main class="taste-wrapper">
<form name="tasteFrm" id="tasteForm" method="post" action="<%= request.getContextPath() %>/member/taste_check.lp">

  <section class="taste-container">
    <h3 class="taste-title">🎧 좋아하는 테마를 골라보세요</h3>
<div class="taste-guide">
 
  <span class="guide-text">
    이미지를 누르면 <strong>미리듣기</strong>를 할 수 있어요
  </span>
<div class="selection-box">
    <span id="selectedResult"></span>
  </div>
  <!-- 🔍 테스트용 선택 결과 표시 -->
<div id="selectedResult" style="margin-top:15px; font-size:14px; color:#555;"></div>
</div>
    <div class="preference-grid">

      <!-- categoryno 기준으로 data-category -->
      <div class="preference-item" data-category="1" data-music="../music/taste_check/pop.mp3">
        <div class="img-wrap"><img src="../images/taste_check/pop.png"></div>
        <div class="preference-label">POP</div>
      </div>

      <div class="preference-item" data-category="2" data-music="../music/taste_check/rock.mp3">
        <div class="img-wrap"><img src="../images/taste_check/rock.png"></div>
        <div class="preference-label">ROCK</div>
      </div>

      <div class="preference-item" data-category="3" data-music="../music/taste_check/jazz.mp3">
        <div class="img-wrap"><img src="../images/taste_check/jazz.png"></div>
        <div class="preference-label">JAZZ</div>
      </div>

      <div class="preference-item" data-category="4" data-music="../music/taste_check/classic.mp3">
        <div class="img-wrap"><img src="../images/taste_check/classic.png"></div>
        <div class="preference-label">CLASSIC</div>
      </div>

      <div class="preference-item" data-category="5" data-music="../music/taste_check/etc.mp3">
        <div class="img-wrap"><img src="../images/taste_check/etc.png"></div>
        <div class="preference-label">ETC</div>
      </div>

    </div>

    <!-- 선택값 담을 hidden -->
    <input type="hidden" name="categoryList" id="categoryList">

    <div class="taste-btn-wrap">
      <button type="button" id="submitBtn" class="taste-btn">완료</button>
    </div>

  </section>
</form>
</main>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script>
$(function () {
	  let previewAudio = new Audio();
	  let currentPreviewItem = null;

	  // 1. 아이템 클릭 이벤트
	  $(".preference-item").on("click", function () {
	    const $item = $(this);
	    const musicSrc = $item.data("music");

	    /* =====================================================
	       CASE 1. 이미 선택됨 + 재생 중 -> 음악 정지 (선택은 유지)
	       결과: spin(회전) 제거, active(그림자/확대) 유지
	    ===================================================== */
	    if ($item.hasClass("active") && $item.hasClass("spin")) {
	      previewAudio.pause();
	      previewAudio.currentTime = 0;
	      $item.removeClass("spin"); // 회전만 멈춤
	      currentPreviewItem = null;
	      updateSelectedResult();
	      return;
	    }

	    /* =====================================================
	       CASE 2. 이미 선택됨 + 정지 상태 -> 선택 완전 해제
	       결과: active(그림자/확대) 제거
	    ===================================================== */
	    if ($item.hasClass("active") && !$item.hasClass("spin")) {
	      $item.removeClass("active");
	      updateSelectedResult();
	      return;
	    }

	    /* =====================================================
	       CASE 3. 새로 선택하거나 다른 곡 재생
	    ===================================================== */
	    // 기존에 재생 중이던 곡 회전 멈추기
	    if (currentPreviewItem) {
	      currentPreviewItem.removeClass("spin");
	      previewAudio.pause();
	    }

	    // 상태 변경: active(확대/그림자)와 spin(5초 회전) 동시 부여
	    $item.addClass("active spin");
	    previewAudio.src = musicSrc;
	    previewAudio.play().catch(e => {
	      console.log("재생 차단 또는 파일 없음");
	    });

	    currentPreviewItem = $item;
	    updateSelectedResult();
	  });

	  // 2. 저장 버튼 클릭
	  $("#submitBtn").on("click", function () {
	    let selectedCategoryNos = [];
	    $(".preference-item.active").each(function () {
	      selectedCategoryNos.push($(this).data("category"));
	    });

	    if (selectedCategoryNos.length === 0) {
	      alert("최소 1개 이상 취향을 선택해주세요.");
	      return;
	    }

	    $("#categoryList").val(selectedCategoryNos.join(","));
	    $("#tasteForm").submit();
	  });

	  updateSelectedResult();
	});

	function updateSelectedResult() {
	  let selectedCategories = [];
	  $(".preference-item.active").each(function () {
	    selectedCategories.push($(this).find(".preference-label").text());
	  });

	  if ($("#selectedResult").length > 0) {
	    if (selectedCategories.length === 0) {
	      $("#selectedResult").text("선택된 취향 없음");
	    } else {
	      $("#selectedResult").text("선택된 취향: " + selectedCategories.join(", "));
	    }
	  }
	}
</script>


<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
</body>
</html>
