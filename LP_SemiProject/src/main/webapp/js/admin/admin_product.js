$(document).ready(function() {
    
    // [기능 1] 전체 선택 / 해제 체크박스 로직
    // 상단 '전체선택' 체크박스 클릭 시
    $("#checkAll").click(function() {
        // checkAll의 상태(checked/unchecked)를 가져와서 하위 체크박스(pseq)에 일괄 적용
        $("input[name='pseq']").prop("checked", $(this).prop("checked"));
    });

    // 개별 상품 체크박스 클릭 시 '전체선택' 상태 동기화
    $(document).on("click", "input[name='pseq']", function() {
        const total = $("input[name='pseq']").length;
        const checked = $("input[name='pseq']:checked").length;
        
        // 전부 선택되었을 때만 '전체선택'에 체크
        $("#checkAll").prop("checked", total === checked);
    });

    // [기능 3] 상품 등록 버튼 클릭 (모달 열기)
    $("#btnOpenRegister").click(function() {
        // 1. 폼 초기화
        $("form[name='productFrm']")[0].reset();
        
        // 2. 모달 타이틀 및 모드 설정
        $("#modalTitle").text("상품 등록");
        $("#modalProductNo").val(""); // 등록이므로 PK 비움
        $("#currentImgText").hide();  // '기존 이미지 유지' 텍스트 숨김
        $("#trackContainer").html('<div class="track-item"><input type="text" name="track_title" class="input-text" placeholder="1번 트랙 제목"></div>'); // 트랙 초기화

        // 3. 폼 액션 설정 (mode=register)
        $("form[name='productFrm']").attr("action", ctxPath + "/admin/admin_product.lp?mode=register");
        
        // 4. 모달 표시
        $("#productModal").css("display", "flex");
    });

    // 모달 닫기 (X 버튼 및 취소 버튼)
    $("#btnCloseModal, #btnCancelModal").click(function() {
        $("#productModal").hide();
    });

});

// [기능 2] 선택 삭제 기능
function goDelete() {
    // 체크된 항목 개수 확인
    const checkedCnt = $("input[name='pseq']:checked").length;
    
    if (checkedCnt === 0) {
        alert("삭제할 상품을 하나 이상 선택해주세요.");
        return;
    }

    if (confirm("선택한 " + checkedCnt + "개의 상품을 정말 삭제하시겠습니까?")) {
        const frm = document.deleteFrm;
        // Controller의 분기 처리를 위해 mode=delete 파라미터 추가
        frm.action = ctxPath + "/admin/admin_product.lp?mode=delete";
        frm.method = "POST";
        frm.submit();
    }
}

// [기능 2-1] 개별 삭제 버튼 (리스트 내 '삭제' 버튼)
function goDeleteOne(productNo) {
    if (confirm("이 상품을 삭제하시겠습니까?")) {
        // 해당 상품의 체크박스만 선택 상태로 변경 후 폼 전송 (또는 별도 location.href 이동)
        // 여기서는 기존 deleteFrm을 재활용하는 방식 사용
        $("input[name='pseq']").prop("checked", false); // 전체 해제
        $("input[name='pseq'][value='" + productNo + "']").prop("checked", true); // 해당 건만 체크
        
        const frm = document.deleteFrm;
        frm.action = ctxPath + "/admin/admin_product.lp?mode=delete";
        frm.method = "POST";
        frm.submit();
    }
}

// [기능 3-1] 상품 수정 모달 열기 (JSP의 '수정' 버튼에서 호출)
function openEditModal(btn) {
    const $btn = $(btn); // 클릭된 버튼 객체
    
    // 데이터 가져오기 (data- 속성)
    const pno = $btn.data("pno");
    const cno = $btn.data("cno");
    const name = $btn.data("name");
    const price = $btn.data("price");
    const stock = $btn.data("stock");
    const point = $btn.data("point");
    const url = $btn.data("url");
    const desc = $btn.data("desc");

    // 폼에 데이터 채우기
    $("#modalProductNo").val(pno);
    $("#modalCategory").val(cno);
    $("#modalName").val(name);
    $("#modalPrice").val(price);
    $("#modalStock").val(stock);
    $("#modalPoint").val(point);
    $("#modalUrl").val(url);
    $("#modalDesc").val(desc);
    
    // 수정 모드 설정
    $("#modalTitle").text("상품 정보 수정");
    $("#currentImgText").show(); // 수정 시에는 이미지 유지 문구 표시
    
    // 폼 액션 설정 (mode=edit)
    $("form[name='productFrm']").attr("action", ctxPath + "/admin/admin_product.lp?mode=edit");
    
    // 트랙 리스트는 복잡하므로 수정 시에는 기존 유지 또는 별도 Ajax 호출 필요 (여기서는 생략/초기화)
    // $("#trackSection").hide(); // 필요 시 수정에서는 트랙 숨김 처리 등
    
    $("#productModal").css("display", "flex");
}

// [기능 3-2] 트랙 추가 버튼 로직
function addTrackField() {
    const cnt = $("#trackContainer .track-item").length + 1;
    const html = `
        <div class="track-item">
            <input type="text" name="track_title" class="input-text" placeholder="${cnt}번 트랙 제목">
            <button type="button" class="btn-remove-track" onclick="removeTrack(this)">X</button>
        </div>
    `;
    $("#trackContainer").append(html);
}

// 트랙 삭제
function removeTrack(btn) {
    $(btn).closest(".track-item").remove();
}