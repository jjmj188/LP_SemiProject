$(document).ready(function(){
    // 문서 로딩 완료 후 실행할 초기화 코드가 있다면 여기에 작성
});

// =======================================================
// 1. 탭 필터링 로직 (전체/배송준비중/배송중/배송완료)
// =======================================================
function filterOrder(category, btn) {
    // 1-1. 버튼 디자인 활성화 (기존 active 제거 후 현재 버튼에 추가)
    const buttons = document.querySelectorAll('.filter-btn');
    buttons.forEach(b => b.classList.remove('active'));
    btn.classList.add('active');

    // 1-2. 테이블 행(tr) 필터링
    const rows = document.querySelectorAll('#orderTableBody tr');
    rows.forEach(row => {
        const status = row.getAttribute('data-status');
        
        // 데이터 없음 메시지 행 등 data-status가 없는 경우 건너뜀
        if(!status) return;

        if (category === 'all') {
            row.style.display = 'table-row';
        } else {
            if (status === category) {
                row.style.display = 'table-row';
            } else {
                row.style.display = 'none';
            }
        }
    });
}

// =======================================================
// 2. 배송 시작 처리 (AJAX) - [수정됨] 통합 컨트롤러 사용
// =======================================================
function goShipping(orderno) {
    
    // 입력값 가져오기 (jQuery 사용)
    const receiverName = $("input#name_" + orderno).val();
    const company      = $("select#company_" + orderno).val();
    const invoice      = $("input#invoice_" + orderno).val();
    
    // 유효성 검사
    if(!receiverName || receiverName.trim() == "") {
        alert("받는 분 이름을 입력해주세요.");
        return;
    }
    if(!invoice || invoice.trim() == "") {
        alert("운송장 번호를 입력해주세요.");
        $("input#invoice_" + orderno).focus();
        return;
    }
    
    if(!confirm("입력한 정보로 배송을 시작하시겠습니까?\n(상태가 '배송중'으로 변경됩니다)")) return;

    // AJAX 요청
    $.ajax({
        // [중요 수정] 별도의 updateDelivery.lp가 아닌 통합 컨트롤러 주소 사용
        url: ctxPath + "/admin/admin_order.lp", 
        type: "POST",
        data: {
            "mode": "updateDelivery", // [중요 수정] 컨트롤러가 이 요청을 구분할 수 있도록 mode값 추가
            "orderno": orderno,
            "receiverName": receiverName,
            "delivery_company": company,
            "invoice_no": invoice
        },
        dataType: "json",
        success: function(json) {
            if(json.result == 1) {
                alert("배송 처리가 완료되었습니다.");
                location.reload(); // 페이지 새로고침하여 상태 반영
            } else {
                alert("처리 중 오류가 발생했습니다. 다시 시도해주세요.");
            }
        },
        error: function(request, status, error) {
            alert("서버 통신 오류: " + error);
        }
    });
}

// =======================================================
// 3. 주소 수정 모달 열기
// =======================================================
function openAddrModal(orderno, postcode, addr1, addr2, addr3) {
    // JSP에서 전달받은 값을 모달 인풋에 세팅
    $("#modal_orderno").val(orderno);
    $("#modal_zipcode").val(postcode);
    $("#modal_addr1").val(addr1);
    $("#modal_addr2").val(addr2);
    $("#modal_addr3").val(addr3);
    
    // 모달창 보이기 (CSS의 display:none을 flex로 변경)
    $("#addrModal").css("display", "flex");
}

// =======================================================
// 4. 모달 닫기
// =======================================================
function closeModal() {
    $("#addrModal").hide();
    // 입력값 초기화 (선택사항)
    $("#modal_addr2").val("");
}

// =======================================================
// 5. 다음(Kakao) 주소 API 실행
// =======================================================
function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            let addr = ''; 
            let extraAddr = ''; 

            // 사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
            if (data.userSelectedType === 'R') { // 도로명 주소
                addr = data.roadAddress;
            } else { // 지번 주소
                addr = data.jibunAddress;
            }

            // 도로명 주소일 때 참고항목 조합
            if(data.userSelectedType === 'R'){
                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
                    extraAddr += data.bname;
                }
                if(data.buildingName !== '' && data.apartment === 'Y'){
                    extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
                }
                if(extraAddr !== ''){
                    extraAddr = ' (' + extraAddr + ')';
                }
                document.getElementById("modal_addr3").value = extraAddr;
            } else {
                document.getElementById("modal_addr3").value = '';
            }

            // 우편번호와 주소 정보를 해당 필드에 넣는다.
            document.getElementById('modal_zipcode').value = data.zonecode;
            document.getElementById('modal_addr1').value = addr;
            // 커서를 상세주소 필드로 이동한다.
            document.getElementById("modal_addr2").focus();
        }
    }).open();
}

// =======================================================
// 6. 주소 적용 버튼 (추후 구현용)
// =======================================================
function applyAddress() {
    alert("현재는 주소 수정 기능의 백엔드가 구현되어 있지 않습니다.\n(DB 업데이트 로직 필요)");
    closeModal();
    // 추후 여기에 주소 수정 AJAX 코드를 작성하면 됩니다.
}