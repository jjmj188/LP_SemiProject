$(function () {
  let previewAudio = new Audio();
  let currentPreviewItem = null;

  // 1. 아이템 클릭 이벤트 (클래스명을 preference-item으로 통일)
  $(".preference-item").on("click", function () {
    const $item = $(this);
    const musicSrc = $item.data("music");

    /* =========================
       CASE 1. 이미 선택됨 + 재생 중 -> 음악만 정지 (선택은 유지)
    ========================= */
    if ($item.hasClass("active") && $item.hasClass("playing")) {
      previewAudio.pause();
      previewAudio.currentTime = 0;
      $item.removeClass("playing spin");
      currentPreviewItem = null;
      
      updateSelectedResult();
      return;
    }

    /* =========================
       CASE 2. 이미 선택됨 + 정지 상태 -> 선택 해제
    ========================= */
    if ($item.hasClass("active") && !$item.hasClass("playing")) {
      $item.removeClass("active");
      
      updateSelectedResult();
      return;
    }

    /* =========================
       CASE 3. 새로 선택하거나 다른 곡 재생
    ========================= */
    // 기존에 재생 중이던 곡이 있다면 정지
    if (currentPreviewItem) {
      currentPreviewItem.removeClass("playing spin");
      previewAudio.pause();
      previewAudio.currentTime = 0;
    }

    // 상태 변경
    $item.addClass("active playing spin");
    previewAudio.src = musicSrc;
    previewAudio.play().catch(e => {
      console.log("자동 재생이 차단되었거나 파일이 없습니다.");
    });

    currentPreviewItem = $item;
    updateSelectedResult();
  });

  /* =========================
     2. 완료 버튼 클릭 -> 폼 전송
  ========================= */
  $("#submitBtn").on("click", function () {
    let selectedCategoryNos = [];

    // 선택된 아이템들에서 data-category 값 수집
    $(".preference-item.active").each(function () {
      selectedCategoryNos.push($(this).data("category"));
    });

    if (selectedCategoryNos.length === 0) {
      alert("최소 1개 이상 취향을 선택해주세요.");
      return;
    }

    // hidden input(#categoryList)에 값 세팅 (예: "1,2,4")
    $("#categoryList").val(selectedCategoryNos.join(","));

    // 폼 제출
    $("#tasteForm").submit();
  });

  // 초기 실행 (기존에 선택된 값이 있다면 화면 갱신)
  updateSelectedResult();
});

/* =========================
   3. 선택 결과 표시 함수
========================= */
function updateSelectedResult() {
  let selectedCategories = [];

  $(".preference-item.active").each(function () {
    selectedCategories.push($(this).find(".preference-label").text());
  });

  // 테스트용 텍스트 출력 영역이 HTML에 있다면 표시
  if ($("#selectedResult").length > 0) {
    if (selectedCategories.length === 0) {
      $("#selectedResult").text("선택된 취향 없음");
    } else {
      $("#selectedResult").text("선택된 취향: " + selectedCategories.join(", "));
    }
  }
}

