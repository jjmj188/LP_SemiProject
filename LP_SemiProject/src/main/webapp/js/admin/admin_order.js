
let currentTargetTd = null;

$(document).on("click", ".btn-addr-edit", function () {
    currentTargetTd = $(this).closest("td");

    let zipRaw = currentTargetTd.find(".zipcode").text();   
    let zip = zipRaw.replace(/[\[\]]/g, '');                 
    let addr1 = currentTargetTd.find(".addr-text").text();
    let addr3 = currentTargetTd.find(".ref-addr").text();
    let addr2 = currentTargetTd.find(".detail-addr").text();

    $("#modal_zipcode").val(zip);
    $("#modal_addr1").val(addr1);
    $("#modal_addr3").val(addr3);
    $("#modal_addr2").val(addr2);
    
    $("#addrModal").css("display", "flex"); 
});

function closeModal() {
    $("#addrModal").hide();
    // 입력값 초기화
    $("#modal_zipcode").val("");
    $("#modal_addr1").val("");
    $("#modal_addr3").val("");
    $("#modal_addr2").val("");
    currentTargetTd = null;
}

function execDaumPostcode() {
    new daum.Postcode({
        oncomplete: function(data) {
            // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드
            var addr = ''; 
            var extraAddr = ''; 

            
            if (data.userSelectedType === 'R') { // 도로명 주소
                addr = data.roadAddress;
            } else { // 지번 주소
                addr = data.jibunAddress;
            }

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

            document.getElementById('modal_zipcode').value = data.zonecode;
            document.getElementById("modal_addr1").value = addr;
            document.getElementById("modal_addr2").focus();
        }
    }).open();
}

function applyAddress() {
    if (!currentTargetTd) return;

    let zip = $("#modal_zipcode").val();
    let addr1 = $("#modal_addr1").val();
    let addr3 = $("#modal_addr3").val();
    let addr2 = $("#modal_addr2").val();

    if(!zip || !addr1) {
        alert("주소를 검색해주세요.");
        return;
    }

    let newHtml = `
        <span class="zipcode">[${zip}]</span>
        <button type="button" class="btn-addr-edit">수정</button><br>
        <span class="addr-text">${addr1}</span>
        <span class="ref-addr">${addr3}</span><br>
        <span class="detail-addr">${addr2}</span>
    `;

    currentTargetTd.html(newHtml);

    console.log("주소가 변경되었습니다.");

    closeModal();
}