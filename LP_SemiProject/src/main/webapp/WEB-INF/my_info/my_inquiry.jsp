<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
  String ctxPath = request.getContextPath();
%>

<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<link rel="stylesheet" href="<%= ctxPath%>/css/my_info/mypage_layout.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_inquiry_list.css">
<link rel="stylesheet" href="<%= ctxPath%>/css/my_info/my_inquiry.css">

<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>

<main class="mypage-wrapper">
  <div class="mypage-container">

    <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath%>/my_info/my_info.lp">프로필 수정</a>
      <a href="<%= ctxPath%>/my_info/my_inquiry.lp" class="active">문의내역</a>
      <a href="<%= ctxPath%>/my_info/my_wish.lp">찜내역</a>
      <a href="<%= ctxPath%>/my_info/my_order.lp">구매내역</a>
      <a href="<%= ctxPath%>/my_info/my_taste.lp">취향선택</a>
    </aside>

    <section class="mypage-content">

      <div class="inquiry-top">
        <h2>문의내역</h2>
        <button type="button" class="btn-write" id="btnOpenInquiry">문의작성</button>
      </div>

      <!-- 목록 -->
      <div class="inquiry-table-wrap">
        <table class="inquiry-table">
          <thead>
            <tr>
              <th style="width:140px;">작성일자</th>
              <th>문의내용</th>
              <th style="width:240px;">관리자 답변</th>
              <th style="width:120px;">처리상태</th>
            </tr>
          </thead>

          <tbody>
            <c:if test="${not empty requestScope.inquiryList}">
              <c:forEach var="dto" items="${requestScope.inquiryList}">
                <tr>
                  <td><c:out value="${dto.inquirydate}" /></td>

                  <td class="td-ellipsis">
                    <c:out value="${dto.inquirycontent}" />
                  </td>

                  <td class="td-ellipsis">
                    <c:choose>
                      <c:when test="${not empty dto.adminreply}">
                        <c:out value="${dto.adminreply}" />
                      </c:when>
                      <c:otherwise>-</c:otherwise>
                    </c:choose>
                  </td>

                  <td>
                    <c:choose>
                      <c:when test="${dto.inquirystatus == '답변완료'}">
                        <span class="status done">답변완료</span>
                      </c:when>
                      <c:otherwise>
                        <span class="status wait"><c:out value="${dto.inquirystatus}" /></span>
                      </c:otherwise>
                    </c:choose>
                  </td>
                </tr>
              </c:forEach>
            </c:if>

            <c:if test="${empty requestScope.inquiryList}">
              <tr>
                <td colspan="4" style="text-align:center; padding:24px;">
                  문의내역이 없습니다.
                </td>
              </tr>
            </c:if>
          </tbody>
        </table>
      </div>

     <!-- ✅ 페이징바 (회원목록 방식 그대로) -->
      <div class="pagebar">
		  <ul class="pagination" style="margin:0;">
		    ${requestScope.pageBar}
		  </ul>
	</div> 
	
<%-- 	    <!-- 페이징 영역 -->
<div class="pagebar">
  <button class="page-btn prev" disabled>
    <i class="fa-solid fa-chevron-left"></i>
  </button>

  <button class="page-num">${requestScope.pageBar}</button>

  <button class="page-btn next">
    <i class="fa-solid fa-chevron-right"></i>
  </button>
</div> --%>


    </section>
  </div>
</main>

<!-- 문의작성 모달(그대로) -->
<div class="modal" id="inquiryModal" aria-hidden="true">
  <div class="modal-dim" id="inquiryModalDim"></div>

  <div class="modal-box" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal-head">
      <h3 id="modalTitle">문의하기</h3>
      <button type="button" class="modal-close" id="btnCloseInquiry" aria-label="닫기">×</button>
    </div>

    <div class="modal-body">
      <form class="inquiry-form" id="inquiryForm" method="post" action="<%=ctxPath%>/my_info/my_inquiry.lp">
        <div class="form-row">
          <div class="form-group half">
            <label>이름</label>
            <input type="text" name="name" value="${sessionScope.loginuser.name}" readonly>
          </div>

          <div class="form-group half">
            <label>전화번호</label>
            <div class="hp-row">
              <input type="text" value="010" readonly> -
              <input type="text" name="hp2" id="hp2" maxlength="4" value="${fn:substring(sessionScope.loginuser.mobile,3,7)}"> -
              <input type="text" name="hp3" id="hp3" maxlength="4" value="${fn:substring(sessionScope.loginuser.mobile,7,11)}">
            </div>
          </div>
        </div>

        <div class="form-group">
          <label>이메일</label>
          <input type="email" name="email" value="${sessionScope.loginuser.email}" readonly>
        </div>

        <div class="form-group">
          <label>문의내용</label>
          <textarea name="inquirycontent" placeholder="문의 내용을 작성해주세요" required></textarea>
        </div>

        <div class="form-group">
          <label>개인정보 수집·이용 안내</label>
          <div class="privacy-box">
            <p>
              수집 항목: 이름, 전화번호, 이메일<br><br>
              수집 목적: 고객 문의 응대 및 처리<br><br>
              보유 기간: 문의 처리 완료 후 1년간 보관<br><br>
              동의를 거부할 권리가 있으나, 동의하지 않을 경우
              문의 서비스 이용이 제한될 수 있습니다.
            </p>
          </div>
        </div>

        <div class="form-bottom">
          <label class="agree-check">
            <input type="checkbox" id="agree" required>
            개인정보 수집·이용에 동의합니다
          </label>

          <button type="submit" class="btn-submit">제출하기</button>
        </div>
      </form>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/footer1.jsp" />
<script src="<%= ctxPath%>/js/my_info/my_inquiry.js"></script>
