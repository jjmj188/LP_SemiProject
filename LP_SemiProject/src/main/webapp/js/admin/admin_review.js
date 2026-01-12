$(document).ready(function(){

    // 1. [전체 선택] 체크박스 클릭 시
    $("#checkAll").click(function(){
        // 전체 선택 박스의 상태(true/false)를 가져옴
        var bool = $(this).prop("checked");
        // 아래쪽 개별 체크박스들(name='reviewno')을 모두 동일하게 변경
        $("input[name='reviewno']").prop("checked", bool);
    });
    
    // 2. [개별] 체크박스 클릭 시 전체선택 박스 상태 동기화
    $("input[name='reviewno']").click(function(){
        // 전체 개수
        var total = $("input[name='reviewno']").length;
        // 체크된 개수
        var checked = $("input[name='reviewno']:checked").length;
        
        // 모두 체크되었으면 '전체 선택'도 체크, 하나라도 풀리면 해제
        if(total == checked) {
            $("#checkAll").prop("checked", true);
        } else {
            $("#checkAll").prop("checked", false);
        }
    });

});

// 선택 삭제 실행 함수
function goDelete() {
    
    // 1. 체크된 항목의 값을 배열에 담기
    var checkArr = [];
    $("input[name='reviewno']:checked").each(function(){
        checkArr.push($(this).val());
    });
    
    // 2. 선택된 항목이 없는 경우
    if(checkArr.length == 0) {
        alert("삭제할 리뷰를 하나 이상 선택해주세요.");
        return;
    }
    
    // 3. 삭제 확인
    if(!confirm("선택한 리뷰 " + checkArr.length + "개를 정말 삭제하시겠습니까?")) {
        return;
    }
    
    // 4. 배열을 콤마(,) 구분 문자열로 변환 (예: "5,12,33")
    var reviewnos = checkArr.join(",");
    
    // 5. AJAX 요청 전송
    $.ajax({
        url: ctxPath + "/admin/admin_review.lp", // 통합 컨트롤러 주소
        type: "POST",
        data: { 
            "mode": "delete",      // 삭제 기능임을 알리는 파라미터
            "reviewnos": reviewnos // 삭제할 번호들
        },
        dataType: "json",
        success: function(json) {
            if(json.result == 1) {
                alert("성공적으로 삭제되었습니다.");
                location.reload(); // 페이지 새로고침하여 목록 갱신
            } else {
                alert(json.message); // 실패 메시지 출력
            }
        },
        error: function(request, status, error) {
            alert("서버 통신 오류가 발생했습니다.\ncode:"+request.status+"\n"+"error:"+error);
        }
    });
}