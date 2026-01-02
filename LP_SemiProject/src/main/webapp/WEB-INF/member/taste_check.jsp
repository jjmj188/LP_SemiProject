<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%
    String userid = (String)session.getAttribute("userid");
    if(userid == null){
        response.sendRedirect("../login/login.jsp");
        return;
    }
%>

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
<form id="tasteForm" method="post" action="taste_submit.jsp">

  <section class="taste-container">
    <h3 class="taste-title">🎧 좋아하는 테마를 골라보세요</h3>

    <div class="preference-grid">

      <!-- categoryno 기준으로 data-category -->
      <div class="preference-item" data-category="1" data-music="../music/taste_check/preview.mp3">
        <div class="img-wrap"><img src="../images/taste_check/라쿠나.png"></div>
        <div class="preference-label">POP</div>
      </div>

      <div class="preference-item" data-category="2" data-music="../music/taste_check/preview.mp3">
        <div class="img-wrap"><img src="../images/taste_check/로제.png"></div>
        <div class="preference-label">ROCK</div>
      </div>

      <div class="preference-item" data-category="3" data-music="../music/taste_check/preview.mp3">
        <div class="img-wrap"><img src="../images/taste_check/리사.png"></div>
        <div class="preference-label">JAZZ</div>
      </div>

      <div class="preference-item" data-category="4" data-music="../music/taste_check/preview.mp3">
        <div class="img-wrap"><img src="../images/taste_check/릴피쉬.png"></div>
        <div class="preference-label">CLASSIC</div>
      </div>

      <div class="preference-item" data-category="5" data-music="../music/taste_check/preview.mp3">
        <div class="img-wrap"><img src="../images/taste_check/릴피쉬.png"></div>
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
$(function(){
	  let audio = new Audio();
	  let playTimer = null;
	  let currentItem = null;

	  // 1. 카테고리 아이템 클릭 이벤트
	  $(".preference-item").on("click", function () {
	    const musicSrc = $(this).data("music");

	    // 토글 처리
	    $(this).toggleClass("active");

	    if ($(this).hasClass("active")) {
	      $(this).addClass("spin");
	    } else {
	      $(this).removeClass("spin");
	    }

	    // 음악 재생 제어 로직
	    if (currentItem && currentItem[0] !== this) {
	      audio.pause();
	      audio.currentTime = 0;
	      clearTimeout(playTimer);
	      if(currentItem) currentItem.removeClass("spin");
	    }

	    // 이미 재생 중인 것을 다시 누르면 멈추기만 하고 리턴 (선택 취소 상황 등)
	    if (currentItem && currentItem[0] === this) {
	       currentItem = null; 
	       return;
	    }

	    // 새 음악 재생
	    audio.src = musicSrc;
	    audio.play();
	    currentItem = $(this);

	    // 30초 후 자동 정지
	    playTimer = setTimeout(() => {
	        audio.pause();
	        audio.currentTime = 0;
	        if (currentItem) {
	            currentItem.removeClass("spin");
	        }
	    }, 30000);
	  }); // preference-item 클릭 이벤트 끝

	  // 2. 완료 버튼 클릭 이벤트 (독립된 위치)
	  $("#submitBtn").on("click", function () {
	    const selected = $(".preference-item.active");

	    if (selected.length === 0) {
	      alert("최소 1개 이상 선택해주세요!");
	      return;
	    }

	    let arr = [];
	    selected.each(function(){
	      arr.push($(this).data("category"));
	    });

	    $("#categoryList").val(arr.join(",")); 
	    audio.pause();
	    
	    // 폼 전송 (Action을 컨트롤러 주소로 변경했는지 확인!)
	    $("#tasteForm").attr("action", "taste_check.lp"); 
	    $("#tasteForm").submit();
	  });

	});
</script>

</body>
</html>
