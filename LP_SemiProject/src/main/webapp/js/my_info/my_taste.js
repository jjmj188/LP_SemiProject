$(function () {
   $("#header").load("../common/header.html");
   $("#footer").load("../common/footer.html");

   // 선택 토글
   $(".taste-item").on("click", function () {
     $(this).toggleClass("active");
   });

   // 저장 버튼
   $(".btn-save").on("click", function () {
     const count = $(".taste-item.active").length;
     if (count === 0) {
       alert("최소 1개 이상 선택해주세요.");
       return;
     }
     alert("취향이 수정되었습니다.");
   });
 });