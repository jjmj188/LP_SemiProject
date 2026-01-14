<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
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
                <tr class="inquiry-row" 
                    data-inquirydate="${dto.inquirydate}"
                    data-inquirycontent="${dto.inquirycontent}"
                    data-adminreply="${dto.adminreply}"
                    data-inquirystatus="${dto.inquirystatus}">
                  <td><c:out value="${dto.inquirydate}" /></td>

                  <td class="td-ellipsis">
                    <c:out value="${fn:substring(dto.inquirycontent, 0, 20)}" />
                    <c:if test="${fn:length(dto.inquirycontent) > 20}">...</c:if>
                  </td>

                  <td class="td-ellipsis">
                    <c:choose>
                      <c:when test="${not empty dto.adminreply}">
                        <c:out value="${fn:substring(dto.adminreply, 0, 20)}" />
                        <c:if test="${fn:length(dto.adminreply) > 20}">...</c:if>
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
    </section>
  </div>
</main>

<!-- 문의 작성 및 상세보기 모달 (하나로 통합) -->
<div class="modal" id="inquiryModal" aria-hidden="true">
  <div class="modal-dim" id="inquiryModalDim"></div>

  <div class="modal-box" role="dialog" aria-modal="true" aria-labelledby="modalTitle">
    <div class="modal-head">
      <h3 id="modalTitle">문의하기</h3>
      <button type="button" class="modal-close" id="btnCloseInquiry" aria-label="닫기">×</button>
    </div>

    <div class="modal-body">
      <!-- 문의 내용 작성 폼 (문의 작성) -->
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
              <input type="text" name="hp2" id="hp2" maxlength="4" value="${fn:substring(sessionScope.loginuser.mobile,3,7)}" readonly> -
              <input type="text" name="hp3" id="hp3" maxlength="4" value="${fn:substring(sessionScope.loginuser.mobile,7,11)}" readonly>
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

      <!-- 문의 내용 확인 -->
      <div class="modal-content" id="modalInquiryContent" style="display:none;">
        <p><strong>작성일자:</strong> <span id="modal-inquirydate"></span></p>
        <p><strong>문의내용:</strong> <span id="modal-inquirycontent"></span></p>
        <p><strong>관리자 답변:</strong> <span id="modal-adminreply"></span></p>
      </div>
    </div>
  </div>
</div>

<jsp:include page="/WEB-INF/footer1.jsp" />

<script type="text/javascript">
$(function () {
  // 문의작성 버튼 클릭 시 모달 열기
  $("#btnOpenInquiry").on("click", function () {
    // 문의 작성 폼 표시
    $("#inquiryForm").show();
    $("#modalInquiryContent").hide();
    $("#modalTitle").text("문의 작성");
    $("#inquiryModal").addClass("open");
    $("body").addClass("no-scroll");
  });

  // 각 tr 클릭 시, 모달에 내용 표시 (상세 보기)
  $(".inquiry-row").on("click", function() {
    var inquirydate = $(this).data("inquirydate");
    var inquirycontent = $(this).data("inquirycontent");
    var adminreply = $(this).data("adminreply");
    var inquirystatus = $(this).data("inquirystatus");

    // 문의 작성 폼 숨기기, 상세보기 표시
    $("#inquiryForm").hide();
    $("#modalInquiryContent").show();
    $("#modalTitle").text("문의 내용 확인");

    // 모달에 데이터 삽입
    $("#modal-inquirydate").text(inquirydate);
    $("#modal-inquirycontent").text(inquirycontent);
    $("#modal-adminreply").text(adminreply || "-");
    $("#modal-inquirystatus").text(inquirystatus);

    // 모달 열기
    $("#inquiryModal").addClass("open");
    $("body").addClass("no-scroll");
  });

  // 모달 닫기
  $("#btnCloseInquiry, #inquiryModalDim").on("click", function() {
    $("#inquiryModal").removeClass("open");
    $("body").removeClass("no-scroll");
  });

  $(document).on("keydown", function (e) {
    if (e.key === "Escape" && $("#inquiryModal").hasClass("open")) {
      $("#inquiryModal").removeClass("open");
      $("body").removeClass("no-scroll");
    }
  });
});
</script>
