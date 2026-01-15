$(document).ready(function(){
    
    // 택배사 입력란에 직접 타이핑 방지 (선택만 가능하게)
    $(document).on("keydown", ".select-courier", function(e){
        e.preventDefault(); 
        return false;
    });

    $(document).on("focus", ".select-courier", function(){
        $(this).blur(); 
    });

});

// 배송 시작 처리 (AJAX)
function goDeliveryStart(orderno) {
    const receiver = $("#receiver_" + orderno).val(); 
    const company = $("#company_" + orderno).val(); 
    const invoice = $("#invoice_" + orderno).val(); 

    if(!receiver) { alert("받는 분 성함을 입력하세요."); return; } 
    if(!company)  { alert("택배사를 선택하세요."); return; } 
    
    // 택배사별 송장번호 유효성 검사
    let regExp_invoice;
    let lengthMsg = "";

	if (company === "CJ대한통운" || company === "한진택배") {
	    regExp_invoice = /^[0-9]{12}$/; // 12자리 숫자
	    lengthMsg = "12자리";
	}		
	 else if (company === "우체국택배") {
        regExp_invoice = /^[0-9]{13}$/; // 13자리 숫자
        lengthMsg = "13자리";
    } else {
        regExp_invoice = /^[0-9]+$/;
        lengthMsg = "숫자";
    }

    if(!invoice || !regExp_invoice.test(invoice)) { 
        alert(company + " 송장번호는 " + lengthMsg + "로 정확히 입력해야 합니다."); 
        $("#invoice_" + orderno).focus(); 
        return; 
    }

    if(!confirm("배송을 시작하시겠습니까?")) return; 

    $.ajax({
        url: ctxPath + "/admin/admin_order.lp", 
        type: "POST", 
        data: {
            "mode": "updateDeliveryStart", // [수정] updateDelivery -> updateDeliveryStart
            "orderno": orderno, 
            "receiverName": receiver, 
            "delivery_company": company, 
            "invoice_no": invoice 
        },
        dataType: "json", 
        success: function(json) {
            if(json.result == 1) { 
                alert("배송 처리가 완료되었습니다."); 
                location.reload(); 
            } else {
                alert("배송 처리 실패."); 
            }
        },
        error: function(request, status, error){
            alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
        }
    });
}

// 배송 완료 처리
function goDeliveryEnd(orderno) {
    if(!confirm("배송완료 처리하시겠습니까?")) return; 
    $.ajax({
        url: ctxPath + "/admin/admin_order.lp", 
        type: "POST", 
        data: { "mode": "updateDeliveryEnd", "orderno": orderno }, // [확인] 일치함
        dataType: "json", 
        success: function(json) {
            if(json.result == 1) { 
                alert("완료되었습니다."); 
                location.reload(); 
            } else {
                alert("처리 실패");
            }
        },
        error: function(request, status, error){
            alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
        }
    });
}

// 주소 수정 모달 제어
function openAddrModal(orderno, postcode, addr1, addr2, addr3) {
    $("#modal_orderno").val(orderno); 
    $("#modal_zipcode").val(postcode);
    $("#modal_addr1").val(addr1); 
    $("#modal_addr2").val(addr2); 
    $("#modal_addr3").val(addr3); 
    $("#addrModal").css("display", "flex"); 
}

function closeModal() { $("#addrModal").hide(); } 

// 다음 주소 API
function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            let addr = (data.userSelectedType === 'R') ? data.roadAddress : data.jibunAddress;
            let extraAddr = ''; 
            if(data.userSelectedType === 'R'){
                if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){ extraAddr += data.bname; }
                if(data.buildingName !== '' && data.apartment === 'Y'){ extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName); }
                if(extraAddr !== ''){ extraAddr = ' (' + extraAddr + ')'; }
                document.getElementById("modal_addr3").value = extraAddr;
            } else { document.getElementById("modal_addr3").value = ''; }
            document.getElementById('modal_zipcode').value = data.zonecode;
            document.getElementById('modal_addr1').value = addr;
            document.getElementById("modal_addr2").focus();
        }
    }).open();
}

// 주소 수정 적용
function applyAddress() {
    const orderno = $("#modal_orderno").val();
    const postcode = $("#modal_zipcode").val();
    const address = $("#modal_addr1").val();
    const detailAddress = $("#modal_addr2").val();
    const extraAddress = $("#modal_addr3").val();

    if(!postcode || !address) { alert("주소를 입력해주세요."); return; }
    if(!confirm("주소 정보를 수정하시겠습니까?")) return;

    $.ajax({
        url: ctxPath + "/admin/admin_order.lp",
        type: "POST",
        data: {
            "mode": "updateOrderAddress", // [수정] updateAddress -> updateOrderAddress
            "orderno": orderno,
            "postcode": postcode,
            "address": address,
            "detailaddress": detailAddress,
            "extraaddress": extraAddress
        },
        dataType: "json",
        success: function(json) {
            if(json.result == 1) {
                alert("수정되었습니다.");
                location.reload();
            } else {
                alert("수정 실패");
            }
        },
        error: function(request, status, error){
            alert("code: "+request.status+"\n"+"message: "+request.responseText+"\n"+"error: "+error);
        }
    });
}