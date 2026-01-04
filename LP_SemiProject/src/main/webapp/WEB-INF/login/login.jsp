<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ taglib prefix="c"   uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>    

<%
    String ctx_Path = request.getContextPath();
   
%>
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<link rel="stylesheet" type="text/css" href="<%= ctx_Path%>/css/login/login.css" />

<script type="text/javascript" src="<%= ctx_Path%>/js/login/login.js"></script>


<!-- Bootstrap CSS -->
<link rel="stylesheet"
      href="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/css/bootstrap.min.css">

<!-- Bootstrap JS -->
<script src="https://cdn.jsdelivr.net/npm/bootstrap@4.6.2/dist/js/bootstrap.bundle.min.js"></script>

<script type="text/javascript">

<%--아이디 저장 쿠키가 있으면 로그인 화면을 자동 완성해주는 UX용 코드--%>
  $(function(){
	
	  <%-- === 쿠키(Cookie) 값을 읽어올 때 자바스크립트를 이용하는 경우 시작 === --%>
	  const cookies = document.cookie; 
	  console.log("쿠키 : ", cookies);
	

	  if(cookies != "") {
		  const arrCookie = cookies.split("; ");
		  
		  for(let i=0; i<arrCookie.length; i++) {
			  const cookie_name = arrCookie[i].substring(0, arrCookie[i].indexOf("="));
			  
			  if(cookie_name == "saveid") {
				  const cookie_value = arrCookie[i].substring(arrCookie[i].indexOf("=")+1); 
				  $('input#loginUserid').val(cookie_value);
				  $('input:checkbox[name="saveid"]').prop("checked", true);
				  break;
			  }
		  }// end of for------------------
	  }	  
	  <%-- === 쿠키(Cookie) 값을 읽어올 때 자바스크립트를 이용하는 경우 끝 === --%>
	  
	  
      // ----------------------------------------------------------------------- //
      
      // == 아이디 찾기에서 close 버튼 또는 x 버튼을 클릭하면 iframe 의 form 태그에 입력된 값을 지우기 == //
      $('button.idFindClose').click(function(){
    	  
    	  const iframe_idFind = document.getElementById("iframe_idFind"); 
	       // 대상 아이프레임을 선택한다.

    	  
	       const iframe_window = iframe_idFind.contentWindow;
	    	 
	       iframe_window.func_form_reset_empty();	
	     
	    
      });// end of $('button.idFindClose').click(function(){})---------------
	  
      
   // == 비밀번호 찾기에서 close 버튼 또는 x 버튼을 클릭하면 새로고침을 해주겠다. == //
      $('button.passwdFindClose').click(function(){
   
    	  javascript:history.go(0);
          // 현재 페이지를 새로고침을 함으로써 모달창에 입력한 userid 와 email 의 값이 텍스트박스에 남겨있지 않고 삭제하는 효과를 누린다. 
    
      });
      
  });// end of $(function(){})------------------------

</script>

<%-- === 로그인을 하기 위한 폼태그 생성하기 시작 === --%>
<!-- HEADER -->

<c:if test="${empty sessionScope.loginuser}">

   <form name="loginFrm" action="<%= ctx_Path%>/login/login.lp" method="post">
      <table id="loginTbl">
    <thead>
        <tr>
            <th>로그인</th>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <span class="label-text">아이디</span>
                <input type="text" name="userid" id="loginUserid" autocomplete="off" />
            </td>
        </tr>
        <tr>
            <td>
                <span class="label-text">비밀번호</span>
                <input type="password" name="pwd" id="loginPwd" />
            </td>
        </tr>
       <tr>
  <td>
    <div class="saveid-line">
      <div class="saveid-right">
        <input type="checkbox" id="saveid" name="saveid" />
        <label for="saveid">아이디저장</label>
      </div>

      <div class="find-links">
        <a data-toggle="modal" data-target="#userIdfind">아이디찾기 |</a> 
        <a data-toggle="modal" data-target="#passwdFind">비밀번호찾기</a>
      </div>
    </div>
  </td>
</tr>
		
		<tr>
		  <td>
		   <button type="button" id="btnSubmit">로그인</button>
		  </td>
		</tr>
		
		<tr>
		  <td>
		    <button type="button"
		      class="btn-register"
		      onclick="location.href='<%= ctx_Path %>/member/member_register.lp'">
		      회원가입
		    </button>
		  </td>
		</tr>
    </tbody>
</table>
      
   </form>
<%-- === 로그인을 하기 위한 폼태그 생성하기 끝 === --%>


<%-- ****** 아이디 찾기 Modal 시작 ****** --%>
<%-- <div class="modal fade" id="userIdfind"> --%> <%-- 만약에 모달이 안보이거나 뒤로 가버릴 경우에는 모달의 class 에서 fade 를 뺀 class="modal" 로 하고서 해당 모달의 css 에서 zindex 값을 1050; 으로 주면 된다. --%> 
  <div class="modal fade" id="userIdfind" data-backdrop="static"> <%-- 만약에 모달이 안보이거나 뒤로 가버릴 경우에는 모달의 class 에서 fade 를 뺀 class="modal" 로 하고서 해당 모달의 css 에서 zindex 값을 1050; 으로 주면 된다. --%>  
    <div class="modal-dialog">
      <div class="modal-content">
      
        <!-- Modal header -->
        <div class="modal-header">
          <h4 class="modal-title">아이디 찾기</h4>
          <button type="button" class="close idFindClose" data-dismiss="modal">&times;</button>
        </div>
        
        <!-- Modal body -->
        <div class="modal-body">
          <div id="idFind">
          	<iframe id="iframe_idFind" style="border: none; width: 100%; height: 350px;" src="<%= ctx_Path%>/login/id_find.lp"> 
          	</iframe>
          </div>
        </div>
        
        <!-- Modal footer -->
        <div class="modal-footer">
          <button type="button" class="btn btn-danger idFindClose" data-dismiss="modal">Close</button>
        </div>
      </div>
      
    </div>
  </div>
<%-- ****** 아이디 찾기 Modal 끝 ****** --%>
  
  
<%-- ****** 비밀번호 찾기 Modal 시작 ****** --%>
  <div class="modal fade" id="passwdFind"> <%-- 만약에 모달이 안보이거나 뒤로 가버릴 경우에는 모달의 class 에서 fade 를 뺀 class="modal" 로 하고서 해당 모달의 css 에서 zindex 값을 1050; 으로 주면 된다. --%>
    <div class="modal-dialog">
      <div class="modal-content">
      
        <!-- Modal header -->
        <div class="modal-header">
          <h4 class="modal-title">비밀번호 찾기</h4>
          <button type="button" class="close passwdFindClose" data-dismiss="modal">&times;</button>
        </div>
        
        <!-- Modal body -->
        <div class="modal-body">
          <div id="pwFind">
          	<iframe style="border: none; width: 100%; height: 350px;" src="<%= ctx_Path%>/login/pwd_find.lp">  
          	</iframe>
          </div>
        </div>
        
        <!-- Modal footer -->
        <div class="modal-footer">
          <button type="button" class="btn btn-danger passwdFindClose" data-dismiss="modal">Close</button>
        </div>
      </div>
      
    </div>
  </div> 
<%-- ****** 비밀번호 찾기 Modal 끝 ****** --%>

</c:if>
<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />







    