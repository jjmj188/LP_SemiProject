<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

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
<style>/* 공통 폼 스타일 */
.form-container {
    list-style-type: none;
    padding: 0;
    margin: 0 auto;
    display: table;
}

.form-container li {
    margin: 20px 0;
}

.form-container label {
    display: inline-block;
    width: 90px;        /* 라벨 위치 통일 */
    font-weight: bold;
    font-size: 16px;   /* 라벨 폰트 통일 */
}

.form-container input {
    width: 240px;      /* 🔥 가로 길이 통일 */
    height: 32px;      /* 🔥 높이 통일 */
    padding: 4px 6px;
    font-size: 14px;   /* 🔥 폰트 크기 통일 */
    box-sizing: border-box;
}
.form-container input,
.form-container label {
    font-family: "Noto Sans KR", Arial, sans-serif;
}

</style>
<script type="text/javascript">
   $(function(){

	
	   const method = "${method}";

	   
	   if(method == "GET") {
		   $('div#div_findResult').hide();
	   }
	   
       if(method == "POST") {
		
		   $('input:text[name="name"]').val('${name}');
		   $('input:text[name="email"]').val('${email}');
	   }    
	       
	   
	   $('input:text[name="email"]').bind('keyup', function(e){
		   if(e.keyCode == 13) {
			  goFind(); 
		   }
	   });
	   
	   $('#btnFind').click(function(){
		    goFind();
		});
	   
	   
   });// end of $(function(){})------------------------
   
   
   // Function Declaration
   function goFind(){

	   const name = $('input:text[name="name"]').val().trim();
	   
	   if(name == "") {
		   alert("성명을 입력하세요");
		   return; // goFind() 함수의 종료
	   }
	   
	   const email = $('input:text[name="email"]').val();
	   
	   const regExp_email = /^[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*@[0-9a-zA-Z]([-_\.]?[0-9a-zA-Z])*\.[a-zA-Z]{2,3}$/i; 
	   // 이메일 정규표현식 객체 생성
	   
	   const bool = regExp_email.test(email);
	   
	   if(!bool) {
		   // 이메일이 정규표현식에 위배된 경우 
		   alert("이메일을 올바르게 입력하세요");
		   return; // goFind() 함수의 종료
	   }
	   
	   const frm = document.idFindFrm;
  <%-- frm.action = "<%= ctxPath%>/login/idFind.up"; --%> 
	   frm.method = "post";
	   frm.submit();
	   
   }// end of function goFind(){}---------------------
   
   
   // 아이디 찾기 모달창에 입력한 input 태그 value 값 초기화 시켜주는 함수 생성하기
   function func_form_reset_empty() {
	   document.querySelector('form[name="idFindFrm"]').reset();
	   $('div#div_findResult').empty(); 
   }// end of function func_form_reset_empty()--------------------
   
</script>

<form name="idFindFrm">

   <ul class="form-container">
  <li>
    <label>성명</label>
    <input type="text" name="name" autocomplete="off" />
  </li>
  <li>
    <label>이메일</label>
    <input type="text" name="email" autocomplete="off" />
  </li>
</ul>

   <div class="my-3 text-center">
   <button type="button" id="btnFind" class="btn btn-dark">찾기</button>
</div>
   
</form>

<div class="my-3 text-center" id="div_findResult">
      아이디 : <span style="color: black; font-size: 16pt; font-weight: bold;">${userid}</span>
</div>















    