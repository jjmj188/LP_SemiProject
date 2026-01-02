$(function () {


   // [추가] 답변하기 버튼 클릭 시 모달 열기
   $(".btn-reply").on("click", function() {
     // 클릭한 줄의 문의 내용을 가져와서 모달에 보여주기 (UX 향상)
     var inquiryText = $(this).closest("tr").find(".content").text();
     $("#modalInquiryText").text(inquiryText);

     $("#inquiryModal").fadeIn(200);
   });

   // [추가] 팝업 닫기
   $(".btn-cancel-modal, .btn-close-modal").on("click", function() {
     $("#inquiryModal").fadeOut(200);
   });

   // [추가] 배경 클릭 시 닫기
   $("#inquiryModal").on("click", function(e) {
     if ($(e.target).is("#inquiryModal")) {
       $(this).fadeOut(200);
     }
   });
 });