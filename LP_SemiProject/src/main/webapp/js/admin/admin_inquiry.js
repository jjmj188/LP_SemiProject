// 1. 모달 열기
function openModal(inquiryno, content, reply) {
    // 문의 번호 세팅
    $("#modalInquiryNo").val(inquiryno);
    
    // 문의 내용 텍스트 세팅
    $("#modalInquiryText").text(content);
    
    // 기존 답변이 있다면 세팅, 없으면 비우기
    if(reply && reply !== 'null') {
         $("#modalReplyContent").val(reply);
    } else {
         $("#modalReplyContent").val("");
    }

    $("#inquiryModal").fadeIn(200);
}

// 2. 모달 닫기
function closeModal() {
    $("#inquiryModal").fadeOut(200);
}

// 3. 답변 등록 제출
function goReply() {
    const replyContent = $("#modalReplyContent").val().trim();
    
    if(replyContent == "") {
        alert("답변 내용을 입력하세요.");
        $("#modalReplyContent").focus();
        return;
    }
    
    if(confirm("답변을 등록하시겠습니까?")) {
        // 폼 전송
        document.replyFrm.submit();
    }
}

// 배경 클릭 시 닫기 이벤트 등
$(document).ready(function(){
    // 배경 클릭 시 모달 닫기
    $("#inquiryModal").on("click", function(e) {
        if ($(e.target).is("#inquiryModal")) {
            closeModal();
        }
    });
});