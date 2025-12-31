<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<script type="text/javascript">

 //	alert("${requestScope.message}"); // 메시지 출력해주기
	alert("${message}");              // 메시지 출력해주기
	
 //	location.href = "${requestScope.loc}"; // 페이지 이동
	location.href = "${loc}";              // 페이지 이동

</script>    