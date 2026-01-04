/**
 * 
 */

window.onload = function(){
	
	// ==== 체크박스 여러개중 라디오 처럼 1개만 선택되도록 만든 것 ==== //
	const checkbox_list = document.querySelectorAll("input[name='product_old']"); 

	for(let elmt of checkbox_list) {
		
		elmt.addEventListener('click', () => {
			
			for(let checkbox of checkbox_list) {
				if(elmt != checkbox) {
				   checkbox.checked = false;
				}
			}// end of for-----------------------
			
		});
		
	}// end of for----------------------
	
	
	// ==== 체크박스 전체선택/전체해제 ==== //
	const allCheck = document.querySelector("input[id='allCheck']"); 
	
	allCheck.addEventListener('click', () => {
		
		const checkbox_list = document.querySelectorAll("input[name='product_usa']"); 
		
		for(let checkbox of checkbox_list) {
			checkbox.checked = allCheck.checked;
		}// end of for----------------- 
		
	});
	
	
	// === 체크박스 전체선택/전체해제 에서 
	//     하위 체크박스에 체크가 1개라도 체크가 해제되면 체크박스 전체선택/전체해제 체크박스도 체크가 해제되고
	//     하위 체크박스에 체크가 모두 체크가 되어지면 체크박스 전체선택/전체해제 체크박스도 체크가 되어지도록 하는 것 === //
	const checkbox_usa_list = document.querySelectorAll("input[name='product_usa']");
	
	// === 이벤트 소스를 잡은것(복수개 이므로 for문을 사용함) === //
	for(let checkbox of checkbox_usa_list) {
		
		checkbox.addEventListener('click', () => {
			
			if(!checkbox.checked) { // 체크박스에 체크를 해제한 클릭인 경우 
				document.querySelector("input[id='allCheck']").checked = false;
			}
			
			else { // 체크박스에 체크를 한 클릭인 경우
				   // ==> name 값이 product_usa 인 모든 체크박스를 검사해서 모든 체크박스가 체크가 되어진 경우라면 
			       //     체크박스 전체선택/전체해제 체크박스에 체크를 해주도록 한다.
				
				let is_check_all = true;
				for(let checkbox of checkbox_usa_list) {
					if(!checkbox.checked) {
						is_check_all = false;
						break;
					}
				}// end of for--------------------------   				   
				
				document.querySelector("input[id='allCheck']").checked = is_check_all; 
			}
			
		});
		
	}// end of for-------------------------
	
	
}// end of window.onload = function(){}--------------------


function openDaumPOST() {

	new daum.Postcode({
	    oncomplete: function(data) {
	        // 팝업에서 검색결과 항목을 클릭했을때 실행할 코드를 작성하는 부분.

	        // 각 주소의 노출 규칙에 따라 주소를 조합한다.
	        // 내려오는 변수가 값이 없는 경우엔 공백('')값을 가지므로, 이를 참고하여 분기 한다.
	        let addr = ''; // 주소 변수
	        let extraAddr = ''; // 참고항목 변수

	        //사용자가 선택한 주소 타입에 따라 해당 주소 값을 가져온다.
	        if (data.userSelectedType === 'R') { // 사용자가 도로명 주소를 선택했을 경우
	            addr = data.roadAddress;
	        } else { // 사용자가 지번 주소를 선택했을 경우(J)
	            addr = data.jibunAddress;
	        }

	        // 사용자가 선택한 주소가 도로명 타입일때 참고항목을 조합한다.
	        if(data.userSelectedType === 'R'){
	            // 법정동명이 있을 경우 추가한다. (법정리는 제외)
	            // 법정동의 경우 마지막 문자가 "동/로/가"로 끝난다.
	            if(data.bname !== '' && /[동|로|가]$/g.test(data.bname)){
	                extraAddr += data.bname;
	            }
	            // 건물명이 있고, 공동주택일 경우 추가한다.
	            if(data.buildingName !== '' && data.apartment === 'Y'){
	                extraAddr += (extraAddr !== '' ? ', ' + data.buildingName : data.buildingName);
	            }
	            // 표시할 참고항목이 있을 경우, 괄호까지 추가한 최종 문자열을 만든다.
	            if(extraAddr !== ''){
	                extraAddr = ' (' + extraAddr + ')';
	            }
	            // 조합된 참고항목을 해당 필드에 넣는다.
	            document.getElementById("extraAddress").value = extraAddr;
	        
	        } else {
	            document.getElementById("extraAddress").value = '';
	        }

	        // 우편번호와 주소 정보를 해당 필드에 넣는다.
	        document.getElementById('postcode').value = data.zonecode;
	        document.getElementById("address").value = addr;
	        // 커서를 상세주소 필드로 이동한다.
	        document.getElementById("detailAddress").focus();
	    }
	}).open(); 	
		
}// end of function openDaumPOST() {}----------------------






