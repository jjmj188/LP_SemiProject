$(document).ready(function(){
    
    // 1. 검색 버튼 클릭 시 검색 실행
    $("button.btn-search").click(function(){
        goSearch();
    });

    // 2. 검색창에서 엔터키 입력 시 검색 실행
    $("input[name='searchWord']").keydown(function(e){
        if(e.keyCode == 13) { // 엔터키
            goSearch();
        }
    });

    // 3. 전체선택 체크박스 로직
    $("#checkAll").click(function(){
        var bool = $(this).prop("checked");
        $("input:checkbox[name='userid']").prop("checked", bool);
    });
    
    // 4. 개별 체크박스 클릭 시 전체선택 체크박스 상태 동기화
    $("input:checkbox[name='userid']").click(function(){
         var total = $("input:checkbox[name='userid']").length;
         var checked = $("input:checkbox[name='userid']:checked").length;
         
         if(total == checked) {
             $("#checkAll").prop("checked", true);
         } else {
             $("#checkAll").prop("checked", false);
         }
    });
    
}); // end of ready


// 검색 실행 함수
function goSearch() {
    const frm = document.searchFrm;
    
    // 통합 Controller 경로로 GET 요청
    frm.action = ctxPath + "/admin/admin_member.lp"; 
    frm.method = "GET";
    frm.submit();
}

// 선택 회원 탈퇴 처리 함수
function goDelete() {
    var checkCnt = $("input:checkbox[name='userid']:checked").length;
    
    if(checkCnt < 1) {
        alert("탈퇴 처리할 회원을 선택하세요.");
        return;
    }
    
    if(confirm("정말로 선택한 " + checkCnt + "명의 회원을 탈퇴 처리하시겠습니까?")) {
        var frm = document.memberFrm;
        
        // mode=delete 파라미터 추가하여 POST 전송
        frm.action = ctxPath + "/admin/admin_member.lp?mode=delete"; 
        frm.method = "POST"; 
        frm.submit();
    }
}