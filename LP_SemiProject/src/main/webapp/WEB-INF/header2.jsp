<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<%
    String ctxPath = request.getContextPath();
    // 세션 목록에서 확인된 'loginAdmin' 이름을 사용하여 로그인 여부를 판단합니다.
    boolean isLogined = (session.getAttribute("loginAdmin") != null || session.getAttribute("loginuser") != null);
%>
<!DOCTYPE html>
<html lang="en">
<head>
  <meta charset="utf-8" />
  <meta name="viewport" content="width=device-width,initial-scale=1" />
  <link rel="preconnect" href="https://fonts.googleapis.com">
  <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
  <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700;800&display=swap" rel="stylesheet">
  <link rel="stylesheet" href="<%= ctxPath%>/css/common/header.css">
  <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>
  <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">
</head>
<body>
	
  <div class="bg-art" aria-hidden="true"></div>

  <div class="wrap">
  
   <header class="topbar">
  <div class="logo">
    <img src="<%= ctxPath%>/images/logo.png" alt="Logo">
  </div>

  <nav class="navlinks" aria-label="Primary">
    <a href="<%= ctxPath%>/index.lp">HOME</a> |
    
    <% if (!isLogined) { %>
      <a href="<%= ctxPath %>/login/login.lp">LOGIN</a> |
    <% } else { %>
      <a href="<%= ctxPath %>/login/logout.lp">LOGOUT</a> |
    <% } %>

    <a href="<%= ctxPath%>/order/cart.lp">CART</a> |
    <a href="<%= ctxPath%>/my_info/my_inquiry.lp">MYPAGE</a>
  </nav>

  <button class="nav-toggle" type="button" aria-label="Open menu" aria-expanded="false">
    <i class="fa-solid fa-bars"></i>
  </button>

  <nav class="navlinks-mobile" aria-label="Mobile Primary">
    <a href="<%= ctxPath%>/index.lp">HOME</a>
    
    <% if (!isLogined) { %>
      <a href="<%= ctxPath%>/login/login.lp">LOGIN</a>
    <% } else { %>
      <a href="<%= ctxPath%>/login/logout.lp">LOGOUT</a>
    <% } %>
  
    <a href="<%= ctxPath%>/order/cart.lp">CART</a>
    <a href="<%= ctxPath%>/my_info/my_inquiry.lp">MY PROFILE</a>
  </nav>
</header>

<script>
  $(function () {
    const $btn = $(".nav-toggle");
    const $menu = $(".navlinks-mobile");

    function closeMenu(){
      $menu.removeClass("is-open");
      $btn.attr("aria-expanded", "false");
      $btn.find("i").removeClass("fa-xmark").addClass("fa-bars");
    }

    function openMenu(){
      $menu.addClass("is-open");
      $btn.attr("aria-expanded", "true");
      $btn.find("i").removeClass("fa-bars").addClass("fa-xmark");
    }

    $btn.on("click", function (e) {
      e.stopPropagation();
      if ($menu.hasClass("is-open")) closeMenu();
      else openMenu();
    });

    $(document).on("click", function () {
      if ($menu.hasClass("is-open")) closeMenu();
    });

    $menu.on("click", function (e) {
      e.stopPropagation();
    });

    $(document).on("keydown", function(e){
      if(e.key === "Escape") closeMenu();
    });

    $(window).on("resize", function(){
      if(window.innerWidth > 768) closeMenu();
    });
  });
</script>
</body>
</html>