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
  let playTimer = null;

  let currentItem = null;
  let isPlaying = false;

  $(".preference-item").on("click", function () {
    const musicSrc = $(this).data("music");

    /* =========================
       🔥 선택 토글
    ========================= */
    if ($(this).hasClass("active")) {
      $(this).removeClass("active");

      if (currentItem && currentItem[0] === this) {
        audio.pause();
        audio.currentTime = 0;
        clearTimeout(playTimer);
        $(this).removeClass("spin");
        isPlaying = false;
        currentItem = null;
      }
      return;
    } else {
      $(this).addClass("active");
    }

    /* =========================
       기존 음악 중지
    ========================= */
    if (currentItem && currentItem[0] !== this) {
      audio.pause();
      audio.currentTime = 0;
      clearTimeout(playTimer);
      currentItem.removeClass("spin");
      isPlaying = false;
    }

    /* =========================
       새 음악 재생
    ========================= */
    audio.src = musicSrc;
    audio.play();
    $(this).addClass("spin");

    currentItem = $(this);
    isPlaying = true;

    playTimer = setTimeout(() => {
      audio.pause();
      audio.currentTime = 0;
      if (currentItem) currentItem.removeClass("spin");
      isPlaying = false;
    }, 30000);
  });
  
//완료 버튼 클릭 시 실행
  $("#submitBtn").on("click", function() {
    
    // 1. 선택된 카테고리들을 배열에 담기
    let selectedArr = [];
    $(".preference-item.active").each(function() {
      selectedArr.push($(this).data("category"));
    });

    // 2. 유효성 검사 (아무것도 안 눌렀을 때)
    if (selectedArr.length === 0) {
      alert("최소 하나 이상의 취향을 선택해주세요!");
      return;
    }

    // 3. 합쳐진 문자열(예: "1,2,5")을 hidden 필드에 대입
    const frm = document.tasteFrm; // form의 name값으로 접근
    frm.categoryList.value = selectedArr.join(",");

    // 4. 서버로 전송
    frm.submit();
  });
});
</script>


<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />
</body>
</html>
