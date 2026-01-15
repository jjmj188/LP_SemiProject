<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>

<%@ page import="admin.model.MemberVO" %>
<%@ page import="admin.model.AdminVO" %>

<%
    String ctxPath = request.getContextPath();

    // 1. 일반 회원 세션 가져오기
    MemberVO loginUser = (MemberVO)session.getAttribute("loginUser");

    // 2. 관리자 세션 가져오기 (Admin_login.java에서 저장한 이름 "loginAdmin")
    AdminVO loginAdmin = (AdminVO)session.getAttribute("loginAdmin");
%>

<header>
    <div class="header-container">
        <div class="logo">
            <a href="<%= ctxPath %>/index.lp">
                <img src="<%= ctxPath %>/images/logo.png" alt="VINYST" style="height: 50px;">
            </a>
        </div>

        <nav>
            <ul class="header-nav">
                <li><a href="<%= ctxPath %>/index.lp">HOME</a></li>
                
                <li class="divider">|</li>

                <%-- 
                    [수정된 로직] 
                    일반 회원(loginUser)도 없고, 관리자(loginAdmin)도 없을 때만 [LOGIN] 표시 
                --%>
                <% if(loginUser == null && loginAdmin == null) { %>
                    
                    <li><a href="<%= ctxPath %>/login/login.lp">LOGIN</a></li>
                    
                <% } else { %>
                    
                    <%-- 둘 중 하나라도 로그인 상태라면 [LOGOUT] 표시 --%>
                    <li><a href="<%= ctxPath %>/login/logout.lp">LOGOUT</a></li>
                    
                <% } %>

                <li class="divider">|</li>

                <li><a href="<%= ctxPath %>/cart/cart.lp">CART</a></li>

                <li class="divider">|</li>

                <% if(loginAdmin != null) { %>
                    
                    <%-- 관리자 로그인 상태라면 [ADMIN] 또는 [MYPAGE]를 눌렀을 때 관리자 페이지로 이동 --%>
                    <li><a href="<%= ctxPath %>/admin/admin_member.lp">ADMIN</a></li>
                    
                <% } else { %>
                    
                    <%-- 일반 회원이거나 비로그인 상태일 때 --%>
                    <li><a href="<%= ctxPath %>/member/mypage.lp">MYPAGE</a></li>
                    
                <% } %>
            </ul>
        </nav>
    </div>
</header>

<style>
    .header-container {
        display: flex;
        justify-content: space-between;
        align-items: center;
        padding: 20px 50px;
    }
    .header-nav {
        list-style: none;
        display: flex;
        gap: 15px;
        font-family: sans-serif;
        font-size: 14px;
        color: #333;
    }
    .header-nav a {
        text-decoration: none;
        color: inherit;
        font-weight: 500;
    }
    .header-nav .divider {
        color: #ccc;
    }
</style>