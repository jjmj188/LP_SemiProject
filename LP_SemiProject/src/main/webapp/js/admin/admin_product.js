$(document).ready(function() {
    
    // [기능 1] 전체 선택 / 해제 체크박스 로직
    $("#checkAll").click(function() {
        $("input[name='pseq']").prop("checked", $(this).prop("checked"));
    });

    $(document).on("click", "input[name='pseq']", function() {
        const total = $("input[name='pseq']").length;
        const checked = $("input[name='pseq']:checked").length;
        $("#checkAll").prop("checked", total === checked);
    });

    // [기능 2] 상품 등록 모달 열기
    $("#btnOpenRegister").click(function() {
        // 1. 폼 초기화
        $("form[name='productFrm']")[0].reset();
        
        // 2. 모달 상태 설정
        $("#modalTitle").text("상품 등록");
        $("#modalProductNo").val(""); // PK 초기화
        $("#currentImgText").hide();  // 기존 이미지 문구 숨김
        
        // 3. 트랙 리스트 초기화 (1번 트랙만 남김)
        $("#trackContainer").html('<div class="track-item"><input type="text" name="track_title" class="input-text" placeholder="1번 트랙 제목"></div>');

        // 4. 폼 액션 설정 (등록 모드)
        [cite_start]// Admin_product.java의 registerProduct 메서드를 호출하기 위해 mode=register로 설정 [cite: 54]
        $("form[name='productFrm']").attr("action", ctxPath + "/admin/admin_product.lp?mode=register");
        
        // 5. 모달 열기
        $("#productModal").css("display", "flex");
    });

    // [기능 3] 모달 닫기
    $("#btnCloseModal, #btnCancelModal").click(function() {
        $("#productModal").hide();
    });

    // [기능 4] 등록/수정 버튼 클릭 시 (유효성 검사 후 전송)
    $("#modalSubmitBtn").click(function(e){
        e.preventDefault(); // 기본 submit 방지

        // 필수 입력값 검사
        const category = $("#modalCategory").val();
        const name = $("#modalName").val().trim();
        const price = $("#modalPrice").val().trim();
        const stock = $("#modalStock").val().trim();
        const point = $("#modalPoint").val().trim();

        if(!name) { alert("제품명을 입력해주세요."); $("#modalName").focus(); return; }
        if(!price) { alert("가격을 입력해주세요."); $("#modalPrice").focus(); return; }
        if(!stock) { alert("재고량을 입력해주세요."); $("#modalStock").focus(); return; }
        if(!point) { alert("포인트를 입력해주세요."); $("#modalPoint").focus(); return; }

        // 유효성 검사 통과 시 폼 전송
        $("form[name='productFrm']").submit();
    });

});

// [기능 5] 트랙 추가 버튼 로직 (HTML 문자열 생성)
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

// [기능 6] 트랙 삭제 로직
function removeTrack(btn) {
    $(btn).closest(".track-item").remove();
}

// [기능 7] 선택 삭제 기능
function goDelete() {
    const checkedCnt = $("input[name='pseq']:checked").length;
    if (checkedCnt === 0) {
        alert("삭제할 상품을 하나 이상 선택해주세요.");
        return;
    }
    if (confirm("선택한 " + checkedCnt + "개의 상품을 정말 삭제하시겠습니까?")) {
        const frm = document.deleteFrm;
        frm.action = ctxPath + "/admin/admin_product.lp?mode=delete";
        frm.method = "POST";
        frm.submit();
    }
}

// [기능 8] 개별 삭제 기능
function goDeleteOne(productNo) {
    if (confirm("이 상품을 삭제하시겠습니까?")) {
        // 임시 폼 생성 후 전송
        let form = document.createElement("form");
        form.setAttribute("method", "post");
        form.setAttribute("action", ctxPath + "/admin/admin_product.lp?mode=delete");
        
        let hiddenField = document.createElement("input");
        hiddenField.setAttribute("type", "hidden");
        hiddenField.setAttribute("name", "pseq");
        hiddenField.setAttribute("value", productNo);
        
        form.appendChild(hiddenField);
        document.body.appendChild(form);
        form.submit();
    }
}

// [기능 9] 수정 모달 열기
function openEditModal(btn) {
    const $btn = $(btn);
    
    // 데이터 바인딩
    $("#modalProductNo").val($btn.data("pno"));
    $("#modalCategory").val($btn.data("cno"));
    $("#modalName").val($btn.data("name"));
    $("#modalPrice").val($btn.data("price"));
    $("#modalStock").val($btn.data("stock"));
    $("#modalPoint").val($btn.data("point"));
    $("#modalUrl").val($btn.data("url"));
    $("#modalDesc").val($btn.data("desc"));
    
    // 수정 모드 설정
    $("#modalTitle").text("상품 정보 수정");
    $("#currentImgText").show(); 
    
    // 액션 변경 (수정 모드)
    $("form[name='productFrm']").attr("action", ctxPath + "/admin/admin_product.lp?mode=edit");
    
    $("#productModal").css("display", "flex");
}