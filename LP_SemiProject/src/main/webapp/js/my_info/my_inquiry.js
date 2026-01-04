$(function () {

  $("#btnOpenInquiry").on("click", function () {
    $("#inquiryModal").addClass("open");
    $("body").addClass("no-scroll");
  });

  function closeInquiryModal() {
    $("#inquiryModal").removeClass("open");
    $("body").removeClass("no-scroll");
    $("#inquiryForm")[0].reset();
  }

  $("#btnCloseInquiry, #inquiryModalDim").on("click", closeInquiryModal);

  $(document).on("keydown", function (e) {
    if (e.key === "Escape" && $("#inquiryModal").hasClass("open")) {
      closeInquiryModal();
    }
  });

  // ✅ submit 중복 바인딩 방지
  $("#inquiryForm").off("submit").on("submit", function (e) {
    e.preventDefault();

    const inquirycontent = $.trim($(this).find("textarea[name='inquirycontent']").val());

    if (!inquirycontent) {
      alert("문의 내용을 입력하세요.");
      return;
    }

    if (!$("#agree").is(":checked")) {
      alert("개인정보 수집·이용 동의가 필요합니다.");
      return;
    }

	// 전송 (POST)
  	const frm = document.getElementById("inquiryForm");
  	frm.method = "post";
  	frm.action = "my_inquiry.lp";
  	frm.submit();
	
    alert("문의가 접수되었습니다.");
    closeInquiryModal();
	
	
  });

  
});
