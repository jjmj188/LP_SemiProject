package admin.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;

public class AdminInquiryReplyEnd extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        
        if("POST".equalsIgnoreCase(method)) {
            
            // 1. 폼에서 넘어온 파라미터 받기
            String inquiryno = request.getParameter("inquiryno");
            String adminreply = request.getParameter("adminreply");
            
            // 2. DAO 호출하여 업데이트 수행
            AdminDAO adao = new AdminDAO();
            int n = adao.replyInquiry(inquiryno, adminreply);
            
            String message = "";
            String loc = "";
            
            if(n == 1) {
                message = "답변이 등록되었습니다.";
                loc = request.getContextPath() + "/admin/admin_inquiry.lp"; // 목록으로 이동
            } else {
                message = "답변 등록 실패";
                loc = "javascript:history.back()";
            }
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
            
        } else {
            // GET 방식 접근 차단
            String message = "잘못된 접근입니다.";
            String loc = "javascript:history.back()";
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
        }
    }
}