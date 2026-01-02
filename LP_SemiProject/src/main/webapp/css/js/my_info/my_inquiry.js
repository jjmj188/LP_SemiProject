$(function () {

	  // 모달 열기
	  $("#btnOpenInquiry").on("click", function () {
	    $("#inquiryModal").addClass("open");
	    $("body").addClass("no-scroll");
	  });

	  // 모달 닫기
	  function closeInquiryModal() {
	    $("#inquiryModal").removeClass("open");
	    $("body").removeClass("no-scroll");
	    $("#inquiryForm")[0].reset();
	  }

	  $("#btnCloseInquiry, #inquiryModalDim").on("click", closeInquiryModal);

	  // ESC 키로 닫기
	  $(document).on("keydown", function (e) {
	    if (e.key === "Escape" && $("#inquiryModal").hasClass("open")) {
	      closeInquiryModal();
	    }
	  });

	  // 제출 검증
	  $("#inquiryForm").on("submit", function (e) {
	    e.preventDefault();

	    const content = $.trim($("textarea[name='content']").val());
	    if (!content) {
	      alert("문의 내용을 입력하세요.");
	      return;
	    }

	    if (!$("#agree").is(":checked")) {
	      alert("개인정보 수집·이용 동의가 필요합니다.");
	      return;
	    }

	    alert("문의가 접수되었습니다.");
	    closeInquiryModal();
	  });

	});