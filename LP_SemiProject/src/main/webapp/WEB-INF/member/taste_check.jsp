<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>취향 선택</title>

  <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.3/dist/css/bootstrap.min.css" rel="stylesheet">
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
  let audio = new Audio();
  let currentPlayingItem = null;

  $(".preference-item").on("click", function () {
    const $item = $(this);
    const musicSrc = $item.data("music");

    /* =========================
       CASE 1️⃣ 선택 + 재생 중 → 음악만 정지
    ========================= */
    if ($item.hasClass("active") && $item.hasClass("playing")) {
      audio.pause();
      audio.currentTime = 0;
      $item.removeClass("playing spin");
      currentPlayingItem = null;

      updateSelectedResult(); // ✅ 추가
      return;
    }

    /* =========================
       CASE 2️⃣ 선택 + 정지 상태 → 선택 해제
    ========================= */
    if ($item.hasClass("active") && !$item.hasClass("playing")) {
      $item.removeClass("active");

      updateSelectedResult(); // ✅ 추가
      return;
    }

    /* =========================
       CASE 3️⃣ 선택 안 됨 → 선택 + 재생
    ========================= */

    // 다른 음악 재생 중이면 정지 (선택은 유지)
    if (currentPlayingItem) {
      currentPlayingItem.removeClass("playing spin");
      audio.pause();
      audio.currentTime = 0;
    }

    $item.addClass("active playing spin");
    audio.src = musicSrc;
    audio.play();

    currentPlayingItem = $item;

    updateSelectedResult(); // ✅ 추가
  });
});

/* =========================
   선택 결과 표시 함수
========================= */
function updateSelectedResult() {
  let selected = [];

  $(".preference-item.active").each(function () {
    selected.push($(this).find(".preference-label").text());
  });

  if (selected.length === 0) {
    $("#selectedResult").text("선택된 취향 없음");
  } else {
    $("#selectedResult").text("선택된 취향 테스트용: " + selected.join(", "));
  }
}

$(function () {
	  // ... 기존 오디오 관련 코드 생략 ...

	  // 완료 버튼 클릭 이벤트 추가
	  $("#submitBtn").on("click", function() {
	    
	    let selectedCategories = [];

	    // active 클래스가 붙은 아이템들의 data-category 값을 가져옴
	    $(".preference-item.active").each(function() {
	        selectedCategories.push($(this).data("category"));
	    });

	    // 1개 이상 선택했는지 유효성 검사
	    if(selectedCategories.length === 0) {
	        alert("최소 1개 이상의 취향을 선택하셔야 합니다.");
	        return;
	    }

	    // 콤마(,)로 연결하여 hidden 필드인 #categoryList에 대입
	    $("#categoryList").val(selectedCategories.join(","));

	    // 폼 전송
	    const frm = document.tasteFrm;
	    frm.submit();
	  });
	});
</script>


<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
</body>
</html>
