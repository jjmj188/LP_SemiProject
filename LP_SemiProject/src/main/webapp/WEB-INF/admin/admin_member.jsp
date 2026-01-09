<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %> 

<%
    String ctxPath = request.getContextPath();
    // /LP_SemiProject
%>

<!DOCTYPE html>
<html>
<head>
<meta charset="UTF-8">
<title>관리자 페이지 - 회원관리</title>

<link rel="stylesheet" href="<%= ctxPath%>/css/admin/admin_layout.css">
<style>
    .member-control {
        display: flex;
        justify-content: space-between;
        align-items: center;
        margin-bottom: 15px;
    }
    .search-box {
        display: flex;
        gap: 5px;
    }
    .search-box input {
        padding: 5px;
        border: 1px solid #ddd;
    }
    .btn-search {
        padding: 5px 10px;
        background: #333;
        color: #fff;
        border: none;
        cursor: pointer;
    }
    .btn-delete {
        padding: 8px 15px;
        background: #d9534f;
        color: white;
        border: none;
        cursor: pointer;
        font-weight: bold;
    }
    .btn-delete:hover { background: #c9302c; }
    
    .member-table { width: 100%; border-collapse: collapse; background: #fff; }
    .member-table th, .member-table td {
        border-bottom: 1px solid #eee;
        padding: 12px;
        text-align: center;
    }
    .member-table th { background: #f9f9f9; font-weight: bold; color: #555; }
    .status-active { color: green; font-weight: bold; }
    .status-out { color: red; font-weight: bold; }
</style>

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

<script type="text/javascript">
    $(document).ready(function(){
        
        // 1. 검색 버튼 클릭 시 검색 실행
        $("button.btn-search").click(function(){
            goSearch();
        });

        // 2. 검색창에서 엔터키 입력 시 검색 실행
        $("input[name='searchWord']").keydown(function(e){
            if(e.keyCode == 13) { // 엔터키
                goSearch();
            }
        });

        // 3. 전체선택 체크박스 로직
        $("input:checkbox[id='checkAll']").click(function(){
            var bool = $(this).prop("checked");
            $("input:checkbox[name='userid']").prop("checked", bool);
        });
        
        // 4. 개별 체크박스 클릭 시 전체선택 체크박스 상태 동기화
        $("input:checkbox[name='userid']").click(function(){
             var total = $("input:checkbox[name='userid']").length;
             var checked = $("input:checkbox[name='userid']:checked").length;
             
             if(total == checked) {
                 $("input:checkbox[id='checkAll']").prop("checked", true);
             } else {
                 $("input:checkbox[id='checkAll']").prop("checked", false);
             }
        });
        
    }); // end of $(document).ready()

    // 검색 실행 함수
    function goSearch() {
        const frm = document.searchFrm;
        frm.action = "<%= ctxPath%>/admin/admin_member.lp";
        frm.method = "GET";
        frm.submit();
    }

    // 선택 회원 탈퇴 처리 함수
    function goDelete() {
        // 체크된 개수 확인
        var checkCnt = $("input:checkbox[name='userid']:checked").length;
        
        if(checkCnt < 1) {
            alert("탈퇴 처리할 회원을 선택하세요.");
            return;
        }
        
        if(confirm("정말로 선택한 " + checkCnt + "명의 회원을 탈퇴 처리하시겠습니까?")) {
            var frm = document.memberFrm;
            frm.action = "<%= ctxPath%>/admin/memberDelete.lp"; // 삭제 컨트롤러로 이동
            frm.method = "POST"; // 삭제는 반드시 POST 방식
            frm.submit();
        }
    }
</script>

</head>
<body>

<jsp:include page="/WEB-INF/header2.jsp"></jsp:include>

<main class="admin-wrapper">
  <div class="admin-container">

    <aside class="admin-menu">
      <a href="<%= ctxPath%>/admin/admin_member.lp" class="active">회원관리</a>
      <a href="<%= ctxPath%>/admin/admin_product.lp">상품관리</a>
      <a href="<%= ctxPath%>/admin/admin_order.lp">주문·배송</a>
      <a href="<%= ctxPath%>/admin/admin_review.lp">리뷰관리</a>
      <a href="<%= ctxPath%>/admin/admin_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath%>/admin/admin_account.lp">회계상태</a>
    </aside>

    <section class="admin-content">
      <h2>회원 관리</h2>

      <div class="member-control">
        
        <form name="searchFrm" class="search-box" onsubmit="return false;">
            <select name="searchType" style="padding: 5px;">
                <option value="userid">아이디</option>
                <option value="name">회원명</option>
            </select>
            <input type="text" name="searchWord" value="${requestScope.searchWord}" placeholder="검색어를 입력하세요">
            <button type="button" class="btn-search">검색</button>
        </form>

        <button type="button" class="btn-delete" onclick="goDelete()">회원 탈퇴</button>
      </div>

      <form name="memberFrm">
          <table class="member-table">
            <thead>
              <tr>
                <th style="width: 50px;"><input type="checkbox" id="checkAll"></th>
                <th>번호</th>
                <th>아이디</th>
                <th>성명</th>
                <th>이메일</th>
                <th>전화번호</th>
                <th>가입일자</th>
                <th>상태</th>
              </tr>
            </thead>

            <tbody>
              <%-- 데이터가 없을 경우 --%>
              <c:if test="${empty requestScope.memberList}">
                  <tr>
                      <td colspan="8" style="padding: 50px; color: #777;">검색된 회원이 없습니다.</td>
                  </tr>
              </c:if>

              <%-- 데이터가 있을 경우 반복 출력 --%>
              <c:if test="${not empty requestScope.memberList}">
                  <c:forEach var="mvo" items="${requestScope.memberList}">
                      <tr>
                        <td>
                            <input type="checkbox" name="userid" value="${mvo.userid}">
                        </td>
                        
                        <td>${mvo.userseq}</td>
                        <td>${mvo.userid}</td>
                        <td>${mvo.name}</td>
                        <td>${mvo.email}</td>
                        <td>${mvo.mobile}</td>
                        <td>${mvo.registerday}</td>
                        
                        <td>
                            <c:if test="${mvo.status == 1}">
                                <span class="status-active">활동중</span>
                            </c:if>
                            <c:if test="${mvo.status == 0}">
                                <span class="status-out">탈퇴</span>
                            </c:if>
                        </td>
                      </tr>
                  </c:forEach>
              </c:if>
            </tbody>
          </table>
      </form>

      <div class="pagination" style="margin-top: 20px; text-align: center;">
        <c:if test="${not empty requestScope.pageBar}">
            ${requestScope.pageBar}
        </c:if>
      </div>

    </section>
  </div>
</main>

<jsp:include page="/WEB-INF/footer2.jsp" />

</body>
</html>