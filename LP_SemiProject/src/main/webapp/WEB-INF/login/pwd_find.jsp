<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String ctxPath = request.getContextPath();
    //     /MyMVC
%>
    
<!-- Required meta tags -->
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

<!-- 1. jQuery -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<!-- Bootstrap CSS -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<!-- Optional JavaScript -->
<script type="text/javascript" src="<%= ctxPath%>/js/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="<%= ctxPath%>/bootstrap-4.6.2-dist/js/bootstrap.bundle.min.js" ></script> 


<!--인증하기버튼 -->
<style>
//* ===== 공통 폰트 기준 ===== */
:root {
  --form-font-size: 13px;
}
.find-menu {
    width: 100%;                 /* ⭐ 핵심 */
    display: flex;
    justify-content: center;     /* 화면 가운데 */
    gap: 30px;
    margin: 20px 0;
}
.find-menu-item {
    display: inline-flex;
    align-items: center;
    font-weight: bold;
    cursor: pointer;
    white-space: nowrap;
}

/* 폼 컨테이너 */
.form-container {
  list-style-type: none;
  padding: 0;
  margin: 0 auto;
  display: table;
}

.form-container li {
  margin: 12px 0; /* 🔽 더 compact */
}

/* 라벨 */
.form-container label {
  display: inline-block;
  width: 90px;
  font-weight: bold;
  font-size: var(--form-font-size);
}

/* input 공통 */
.form-container input,
#div_confirm input {
  width: 220px;
  height: 30px;
  padding: 4px 6px;
  font-size: var(--form-font-size);
  box-sizing: border-box;
}

/* 인증코드 안내 문구 */
#div_confirm span {
  font-size: 12px;
}

/* 버튼 */
.btn-dark,
.btn-info {
  font-size: 13px;
  padding: 7px 26px;
}

</style>
<script type="text/javascript">
   $(function(){
       const method = "${method}";
       const find_method = "${find_method}";

       // 1. 초기 UI 세팅 (POST 시 상태 유지)
       if(method == "POST") {
           $('input:text[name="userid"]').val("${userid}");
           
           if(find_method == "mobile") {
               setFindMethod('mobile'); // 휴대폰 탭 고정
               $('input:text[name="mobile"]').val("${mobile}");
           } else {
               setFindMethod('email'); // 이메일 탭 고정
               $('input:text[name="email"]').val("${email}");
           }
           
           // 발송 성공 시 찾기 버튼 숨기기
           if("${isUserExists}" == "true" && "${sendSuccess}" == "true") {
               $('#btnFind').hide();
           }
       } else {
           $('div#div_findResult').hide();
       }
       
       // 2. 탭 클릭 이벤트
       $('.find-menu-item').click(function(){
           const id = $(this).attr('id');
           const mode = (id == 'btn_email') ? 'email' : 'mobile';
           setFindMethod(mode);
       });

       // 3. 엔터키 이벤트<키보드엔터 고유번호 ==13 엔터를 눌렀을경우>
       $('input:text[name="email"], input:text[name="mobile"]').bind('keyup', function(e){
           if(e.keyCode == 13) { goFind(); }
       });
       
       $('#btnFind').click(function(){ goFind(); });
       
       // 4. 인증하기 버튼 클릭
       $(document).on('click', 'button.btn-info', function(){
           const input_confirmCode = $('input:text[name="input_confirmCode"]').val().trim(); 
           if(input_confirmCode == "") {
               alert("인증코드를 입력하세요!!");
               return;
           }
           
           const frm = document.verifyCertificationFrm;
           frm.userCertificationCode.value = input_confirmCode;
           frm.userid.value = $('input:text[name="userid"]').val();
           
           frm.action = "<%= ctxPath%>/login/verifyCertification.lp";
           frm.method = "post";
           frm.submit();   
       });
   });

   // [중요] UI 전환 함수 정의
   function setFindMethod(mode) {
       $('.find-menu-item').css({'color': '#888', 'border-bottom': 'none'});
       $('input[name="find_method"]').val(mode);

       if(mode == 'email') {
           $('#btn_email').css({'color': '#000', 'border-bottom': '2px solid #000'});
           $('#li_email').show();
           $('#li_mobile').hide();
       } else {
           $('#btn_mobile').css({'color': '#000', 'border-bottom': '2px solid #000'});
           $('#li_email').hide();
           $('#li_mobile').show();
       }
   }

   function goFind(){
       const userid = $('input:text[name="userid"]').val().trim();
       if(userid == "") { alert("아이디를 입력하세요!!"); return; }
       
       const mode = $('input[name="find_method"]').val();
       if(mode == 'email') {
           const email = $('input:text[name="email"]').val();
           const regExp_email =  /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i; 
           if(!regExp_email.test(email)) { alert("이메일을 올바르게 입력하세요."); return; }
       } else {
           const mobile = $('input:text[name="mobile"]').val().trim();
           if(mobile == "") { alert("휴대폰 번호를 입력하세요!!"); return; }
       }
       
       const frm = document.pwdFindFrm;
       frm.method = "post";
       frm.action = "<%= ctxPath%>/login/pwd_find.lp"; 
       frm.submit();
   }
</script>


<div class="find-menu mb-4">
    <div id="btn_email" class="find-menu-item active" style="margin: 0 15px; cursor: pointer; font-weight: bold;">이메일로 인증</div>
    <div id="btn_mobile" class="find-menu-item" style="margin: 0 15px; cursor: pointer; font-weight: bold; color: #888;">휴대폰으로 인증</div>
</div>

<form name="pwdFindFrm">
   <input type="hidden" name="find_method" value="email" /> 
   
   <ul class="form-container">
      <li>
          <label>아이디</label>
          <input type="text" name="userid" autocomplete="off" /> 
      </li>
      
      <li id="li_email">
          <label>이메일</label>
          <input type="text" name="email" autocomplete="off" /> 
      </li>

      <li id="li_mobile" style="display: none;">
          <label>휴대폰번호</label>
          <input type="text" name="mobile" placeholder="'-' 제외 숫자만" autocomplete="off" /> 
      </li>
   </ul> 

   <div class="my-3 text-center">
       <button type="button" id="btnFind" class="btn btn-dark">인증번호 발송</button>
   </div>
</form>
<div class="my-3 text-center" id="div_findResult">
   
  <%-- 사용자가 존재하지 않는 경우 --%>
   <c:if test="${method == 'POST' && isUserExists == false}">
       <span style="color: red;">사용자 정보가 없습니다</span>
   </c:if>
   
   <%-- 사용자가 존재하고 발송까지 성공한 경우 --%>
   <c:if test="${isUserExists == true && sendSuccess == true}">
       <div id="div_confirm">
           <span style="font-size: 10pt; color: dark;">
               인증코드가 발송되었습니다.<br>
               인증코드를 입력해주세요.
           </span>
           <br>
           <input type="text" name="input_confirmCode" class="mt-2" />
           <br><br> 
           <button type="button" class="btn btn-info">인증하기</button>
       </div>
       
       <script type="text/javascript">
           // 성공 시 찾기 버튼을 숨깁니다.
           $('#btnFind').hide();
       </script>
   </c:if>
   
</div>


<%-- 인증하기 form --%>
<form name="verifyCertificationFrm">
	<input type="hidden" name="userCertificationCode" />
	<input type="hidden" name="userid" />
</form>













    