<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
%>

<link rel="stylesheet" href="<%= ctxPath %>/css/my_info/mypage_layout.css?v=1.1">
<link rel="stylesheet" href="<%= ctxPath %>/css/my_info/my_taste.css?v=1.1">
  <!-- HEADER -->
<jsp:include page="/WEB-INF/header1.jsp"></jsp:include>
<main class="mypage-wrapper">
  <div class="mypage-container">

    <aside class="mypage-menu">
      <h3>마이페이지</h3>
      <a href="<%= ctxPath %>/my_info/my_info.lp">프로필 수정</a>
      <a href="<%= ctxPath %>/my_info/my_inquiry.lp">문의내역</a>
      <a href="<%= ctxPath %>/my_info/my_wish.lp">찜내역</a>
      <a href="<%= ctxPath %>/my_info/my_order.lp">구매내역</a>
      <a href="<%= ctxPath %>/my_info/my_taste.lp" class="active">취향선택</a>
    </aside>

    <form id="tasteForm" class="mypage-content" method="post" action="<%= ctxPath %>/my_info/my_taste.lp">
      
      <h2>취향 선택 <small style="font-size:14px; color:#888;">(항목을 클릭하면 음악이 재생됩니다)</small><br><div id="selectedResult" class="selected-info"></div></h2>
<div class="preference-grid">

  <!-- POP -->
  <div class="preference-item
       <c:if test='${fn:contains(prefList, 1)}'>active</c:if>"
       data-category="1"
       data-music="<%= ctxPath %>/music/taste_check/pop.mp3">

    <div class="img-wrap">
      <img src="<%= ctxPath %>/images/taste_check/pop.png">
      <div class="play-overlay"><i class="fas fa-play"></i></div>
    </div>
    <div class="preference-label">POP</div>
  </div>

  <!-- ROCK -->
  <div class="preference-item
       <c:if test='${fn:contains(prefList, 2)}'>active</c:if>"
       data-category="2"
       data-music="<%= ctxPath %>/music/taste_check/rock.mp3">

    <div class="img-wrap">
      <img src="<%= ctxPath %>/images/taste_check/rock.png">
      <div class="play-overlay"><i class="fas fa-play"></i></div>
    </div>
    <div class="preference-label">ROCK</div>
  </div>

  <!-- JAZZ -->
  <div class="preference-item
       <c:if test='${fn:contains(prefList, 3)}'>active</c:if>"
       data-category="3"
       data-music="<%= ctxPath %>/music/taste_check/jazz.mp3">

    <div class="img-wrap">
      <img src="<%= ctxPath %>/images/taste_check/jazz.png">
      <div class="play-overlay"><i class="fas fa-play"></i></div>
    </div>
    <div class="preference-label">JAZZ</div>
  </div>

  <!-- CLASSIC -->
  <div class="preference-item
       <c:if test='${fn:contains(prefList, 4)}'>active</c:if>"
       data-category="4"
       data-music="<%= ctxPath %>/music/taste_check/classic.mp3">

    <div class="img-wrap">
      <img src="<%= ctxPath %>/images/taste_check/classic.png">
      <div class="play-overlay"><i class="fas fa-play"></i></div>
    </div>
    <div class="preference-label">CLASSIC</div>
  </div>

  <!-- ETC -->
  <div class="preference-item
       <c:if test='${fn:contains(prefList, 5)}'>active</c:if>"
       data-category="5"
       data-music="<%= ctxPath %>/music/taste_check/etc.mp3">

    <div class="img-wrap">
      <img src="<%= ctxPath %>/images/taste_check/etc.png">
      <div class="play-overlay"><i class="fas fa-play"></i></div>
    </div>
    <div class="preference-label">ETC</div>
  </div>

</div>

     

      <input type="hidden" name="categoryList" id="categoryList">
      
      <div class="btn-wrap">
        <button type="button" id="submitBtn">저장하기</button>
      </div>

    </form>
  </div>
</main>



 

  </div>
</div>
<!-- FOOTER -->
<jsp:include page="/WEB-INF/footer1.jsp" />

<script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
<script src="<%= ctxPath %>/js/my_info/my_taste.js"></script>


