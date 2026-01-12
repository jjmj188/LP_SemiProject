$(function () {
  
	  // 1. 전체선택 체크박스 로직
	  $("#checkAll").click(function(){
	      $("input[name='pseq']").prop("checked", $(this).prop("checked"));
	  });
	  
	  $("input[name='pseq']").click(function(){
	      var total = $("input[name='pseq']").length;
	      var checked = $("input[name='pseq']:checked").length;
	      $("#checkAll").prop("checked", total == checked);
	  });
	
	  // 2. 모달 열기/닫기 이벤트 바인딩
	  $("#btnOpenRegister").on("click", openRegisterModal);
	  $("#btnCloseModal, #btnCancelModal").on("click", closeModal);
	  
	  // 모달 배경 클릭 시 닫기
	  $("#productModal").on("click", function(e) {
	    if ($(e.target).is("#productModal")) {
	      closeModal();
	    }
	  });
	
	});
	
	// 모달 닫기 함수
	function closeModal() {
	    $("#productModal").fadeOut(200);
	}
	
	// [기능] 상품 등록 모달 열기
	function openRegisterModal() {
	    document.productFrm.reset();
	    $("#modalProductNo").val(""); // 등록 모드임으로 PK값 비움
	    
	    // 트랙 컨테이너 초기화
	    $("#trackContainer").html('<div class="track-item"><input type="text" name="track_title" class="input-text" placeholder="1번 트랙 제목"></div>');
	    
	    $("#modalTitle").text("상품 등록");
	    $("#modalSubmitBtn").text("등록하기");
	    $("#currentImgText").hide();
	    $("#trackSection").show();
	    
	    // 등록 모드로 action 설정
	    document.productFrm.action = ctxPath + "/admin/admin_product.lp?mode=register";
	    $("#productModal").css("display", "flex").hide().fadeIn(200);
	}
	
	// [기능] 상품 수정 모달 열기
	function openEditModal(btn) {
	    // data 속성값 가져오기
	    var pno = $(btn).data("pno");
	    var cno = $(btn).data("cno");
	    var name = $(btn).data("name");
	    var price = $(btn).data("price");
	    var stock = $(btn).data("stock");
	    var point = $(btn).data("point");
	    var url = $(btn).data("url");
	    var desc = $(btn).data("desc");
	
	    // 폼 값 채우기
	    $("#modalProductNo").val(pno);
	    $("#modalCategory").val(cno);
	    $("#modalName").val(name);
	    $("#modalPrice").val(price);
	    $("#modalStock").val(stock); // 여기에 기존 재고가 채워짐 -> 20으로 수정 가능
	    $("#modalPoint").val(point);
	    $("#modalUrl").val(url);
	    $("#modalDesc").val(desc);
	
	    $("#modalTitle").text("상품 수정");
	    $("#modalSubmitBtn").text("수정하기");
	    $("#currentImgText").show();
	    $("#trackSection").hide(); // 수정 시 트랙 목록은 숨김 (필요시 보이게 수정 가능)
	
	    // ★ 수정 모드로 action 설정 (중요)
	    document.productFrm.action = ctxPath + "/admin/admin_product.lp?mode=edit";
	    
	    $("#productModal").css("display", "flex").hide().fadeIn(200);
	}
	
	// [기능] 선택 상품 삭제
	function goDelete() {
	    if($("input[name='pseq']:checked").length == 0) {
	        alert("삭제할 상품을 선택하세요.");
	        return;
	    }
	    if(confirm("정말 삭제하시겠습니까? (관련 트랙 정보도 모두 삭제됩니다)")) {
	        var frm = document.deleteFrm;
	        frm.action = ctxPath + "/admin/admin_product.lp?mode=delete";
	        frm.method = "POST";
	        frm.submit();
	    }
	}

	// [기능] 개별 상품 삭제
	function goDeleteOne(pno) {
	    if(confirm("이 상품을 삭제하시겠습니까?")) {
	        var form = document.createElement("form");
	        form.method = "POST";
	        form.action = ctxPath + "/admin/admin_product.lp?mode=delete";
	        
	        var input = document.createElement("input");
	        input.type = "hidden";
	        input.name = "pseq"; 
	        input.value = pno;
	        
	        form.appendChild(input);
	        document.body.appendChild(form);
	        form.submit();
	    }
	}

	// [기능] 트랙 추가 버튼
	function addTrackField() {
    const container = document.getElementById("trackContainer");
    const count = container.children.length + 1;
    const div = document.createElement("div");
    div.className = "track-item";
    div.innerHTML = `<input type="text" name="track_title" class="input-text" placeholder="${count}번 트랙 제목"><button type="button" class="btn-remove-track" onclick="this.parentElement.remove()">x</button>`;
    container.appendChild(div);
}