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
.btn-info {
  background-color: #fff !important;
  color: #000 !important;
  border: 1px solid #000 !important;
}

.btn-info:hover {
  background-color: #000 !important;
  color: #fff !important;
}
</style>
<script type="text/javascript">

   $(function(){

	   const method = "${method}";
	   if(method == "GET") {
		   $('div#div_findResult').hide();
	   }
	   
       if(method == "POST") {
	       $('input:text[name="userid"]').val("${userid}");
		   $('input:text[name="email"]').val("${email}");
    	   
		   if(${requestScope.isUserExists == true && requestScope.sendMailSuccess == true}) {
			   $('button.btn-success').hide(); // "찾기" 버튼 숨기기 
		   }
	   }    
	       
	   
	   $('input:text[name="email"]').bind('keyup', function(e){
		   if(e.keyCode == 13) {
			  goFind(); 
		   }
	   });
	   
	   $('#btnFind').click(function(){
		    goFind();
		});
	   
	   
	   // === 인증하기 버튼 클릭시 이벤트 처리해주기 시작 === //
	   $('button.btn-info').click(function(){
		   
		   const input_confirmCode = $('input:text[name="input_confirmCode"]').val().trim(); 
		   
		   if(input_confirmCode == "") {
			   alert("인증코드를 입력하세요!!");
			   return; // 종료
		   }
		   
		   const frm = document.verifyCertificationFrm;
		   frm.userCertificationCode.value = input_confirmCode;
		   frm.userid.value = $('input:text[name="userid"]').val();
		   
		   frm.action = "<%= ctxPath%>/login/verifyCertification.lp";
		   frm.method = "post";
		   frm.submit();   
	   });
	   // === 인증하기 버튼 클릭시 이벤트 처리해주기 끝 === //
	   
   });// end of $(function(){})------------------------
   
   
   // Function Declaration
   function goFind(){

	   const userid = $('input:text[name="userid"]').val().trim();
	   
	   if(userid == "") {
		   alert("아이디를 입력하세요!!");
		   return; // goFind() 함수의 종료
	   }
	   
	   const email = $('input:text[name="email"]').val();
	   
	   const regExp_email = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i; 
	   // 이메일 정규표현식 객체 생성
	   
	   const bool = regExp_email.test(email);
	   
	   if(!bool) {
		   // 이메일이 정규표현식에 위배된 경우 
		   alert("이메일을 올바르게 입력하세요.");
		   return; // goFind() 함수의 종료
	   }
	   
	   const frm = document.pwdFindFrm;
	   frm.method = "post";
	   frm.submit();
	   
   }// end of function goFind(){}---------------------
   
   
</script>

<form name="pwdFindFrm">

   <ul style="list-style-type: none;">
      <li style="margin: 25px 0">
          <label style="display: inline-block; width: 90px;">아이디</label>
          <input type="text" name="userid" size="25" autocomplete="off" /> 
      </li>
      <li style="margin: 25px 0">
          <label style="display: inline-block; width: 90px;">이메일</label>
          <input type="text" name="email" size="25" autocomplete="off" /> 
      </li>
   </ul> 

   <div class="my-3 text-center">
   <button type="button" id="btnFind" class="btn btn-dark">찾기</button>
</div>
   
</form>

<div class="my-3 text-center" id="div_findResult">
   
   <c:if test="${requestScope.isUserExists == false}">
       <span style="color: red;">사용자 정보가 없습니다</span>
   </c:if>
   
   <c:if test="${requestScope.isUserExists == true && requestScope.sendMailSuccess == true}">
       <span style="font-size: 10pt;">
	       인증코드가 ${requestScope.email}로 발송되었습니다.<br>
	       인증코드를 입력해주세요
	   </span>
	   <br>
	   <input type="text" name="input_confirmCode" />
	   <br><br> 
	   <button type="button" class="btn btn-info">인증하기</button>
   </c:if>
   
   <c:if test="${requestScope.isUserExists == true && requestScope.sendMailSuccess == false}">
       <span style="color: red;">메일발송이 실패했습니다</span>
   </c:if>
   
</div>


<%-- 인증하기 form --%>
<form name="verifyCertificationFrm">
	<input type="hidden" name="userCertificationCode" />
	<input type="hidden" name="userid" />
</form>













    