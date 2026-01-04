<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<%
    String ctxPath = request.getContextPath();
 
%>
<!-- 1. jQuery -->
<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<!-- Bootstrap CSS -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<%-- Required meta tags --%>
<meta charset="utf-8">
<meta name="viewport" content="width=device-width, initial-scale=1, shrink-to-fit=no">

<%-- Bootstrap CSS --%>
<link rel="stylesheet" type="text/css" href="<%= ctxPath%>/bootstrap-4.6.2-dist/css/bootstrap.min.css" > 

<%-- Optional JavaScript --%>
<script type="text/javascript" src="<%= ctxPath%>/js/jquery-3.7.1.min.js"></script>
<script type="text/javascript" src="<%= ctxPath%>/bootstrap-4.6.2-dist/js/bootstrap.bundle.min.js" ></script>

<style type="text/css">
  /* 부트스트랩이 안 먹을 때를 대비한 수동 스타일 */
  .btn-dark {
    background-color: #343a40 !important;
    color: white !important;
    border: none !important;
    padding: 10px 20px;
    cursor: pointer;
  }
</style>
<script type="text/javascript">
    $(function(){
    	
    	$('button.btn-dark').click(function(){
    		
    		const pwd  = $('input:password[name="pwd"]').val();
			const pwd2 = $('input:password[id="pwd2"]').val();
			
			if(pwd != pwd2) {
				alert("암호가 일치하지 않습니다.");
				$('input:password[name="pwd"]').val("");
				$('input:password[id="pwd2"]').val("");
				return; // 종료
			}
			else{
				const regExp_pwd = /^.*(?=^.{8,15}$)(?=.*\d)(?=.*[a-zA-Z])(?=.*[^a-zA-Z0-9]).*$/g; 
				// 숫자/문자/특수문자 포함 형태의 8~15자리 이내의 암호 정규표현식 객체 생성 
				
				const bool = regExp_pwd.test(pwd);
				
				if(!bool) {
					// 암호가 정규표현식에 위배된 경우
					alert("암호는 8글자 이상 15글자 이하에 영문자,숫자,특수기호가 혼합되어야만 합니다.");
					$('input:password[name="pwd"]').val("");
					$('input:password[id="pwd2"]').val("");
					return; // 종료
				}
				else {
					// 암호가 정규표현식에 맞는 경우
			    	const frm = document.pwdUpdateEndFrm;
			   <%-- frm.action = "<%= ctxPath%>/login/pwdUpdateEnd.up"; --%>
			    	frm.method = "post";
			    	frm.submit();
				}
			}
    		
    	});// end of $('button.btn-dark').click(function(){})----------------
    	
    });// end of $(function(){})--------------------------
</script>

<c:if test="${requestScope.method == 'GET'}">
    <form name="pwdUpdateEndFrm">
	   <div class="div_pwd" style="text-align: center;">
	      <span style="color: black; font-size: 12pt;">새암호</span><br/> 
	      <input type="password" name="pwd" size="25" />
	   </div>
	   
	   <div class="div_pwd" style="text-align: center;">
	   	  <span style="color: black; font-size: 12pt;">새암호확인</span><br/>
	      <input type="password" id="pwd2" size="25" />
	   </div>
	   
	   <input type="hidden" name="userid" value="${requestScope.userid}">
	   
       <div style="text-align: center;">
	      <button type="button" class="btn btn-dark">암호변경하기</button>
	   </div>
	</form>	   
</c:if>

<c:if test="${requestScope.method == 'POST'}">
	<div style="text-align: center; font-size: 14pt; color: navy;">
	   <c:if test="${requestScope.n == 1}">
	      사용자 ID ${requestScope.userid}님의 비밀번호가 새로이 변경되었습니다.
	   </c:if>
	   
	   <c:if test="${requestScope.n == 0}">
	      SQL구문 오류가 발생되어 비밀번호 변경을 할 수 없습니다.
	   </c:if>
   </div>
</c:if>
<script type="text/javascript">
    $(document).ready(function(){
        const n = "${requestScope.n}";
        const method = "${requestScope.method}";

        if(method == "POST") {
            if(n == "1") {
                alert("비밀번호가 성공적으로 변경되었습니다.\n새로운 비밀번호로 로그인해주세요.");
                
                // 팝업/모달 내부가 아니라 "전체 브라우저 화면"을 로그인 페이지로 바꿉니다.
                top.location.href = "<%= request.getContextPath()%>/login/login.lp";
            }
            else if(n == "-1") {
                alert("현재 사용 중인 비밀번호와 동일한 비밀번호는 보안상 사용이 불가합니다.");
                history.back();
            }
            else {
                alert("비밀번호 변경에 실패하였습니다.");
                history.back();
            }
        }
    });
</script>















   