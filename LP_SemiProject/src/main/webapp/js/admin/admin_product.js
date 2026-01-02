$(function () {
  // 공통 헤더/푸터 로드
  $("#header").load("../common/header.html");
  $("#footer").load("../common/footer.html");

  // [추가] 팝업 열기 (상품등록 버튼 클릭 시)
  $(".btn-add").on("click", function() {
    $("#productModal").fadeIn(200);
  });

  // [추가] 팝업 닫기 (취소 버튼, X 버튼 클릭 시)
  $(".btn-cancel-modal, .btn-close-modal").on("click", function() {
    $("#productModal").fadeOut(200);
  });

  // [추가] 배경 클릭 시 닫기
  $("#productModal").on("click", function(e) {
    if ($(e.target).is("#productModal")) {
      $(this).fadeOut(200);
    }
  });
});