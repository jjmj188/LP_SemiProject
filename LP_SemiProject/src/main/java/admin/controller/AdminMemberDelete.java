package admin.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;

public class AdminMemberDelete extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        
        // POST 방식일 때만 동작 (보안상 GET으로 삭제 금지)
        if("POST".equalsIgnoreCase(method)) {
            
            // 1. JSP에서 넘어온 체크박스 값들(배열) 받기
            String[] userids = request.getParameterValues("userid");
            
            String message = "";
            String loc = "";
            
            if(userids != null && userids.length > 0) {
                // 2. DAO 호출
                InterAdminDAO adao = new AdminDAO();
                int n = adao.deleteMember(userids);
                
                if(n > 0) {
                    message = "선택한 회원이 탈퇴 처리되었습니다.";
                    loc = request.getContextPath() + "/admin/admin_member.lp"; // 목록으로 이동
                } else {
                    message = "탈퇴 처리에 실패했습니다.";
                    loc = "javascript:history.back()";
                }
            } else {
                message = "선택된 회원이 없습니다.";
                loc = "javascript:history.back()";
            }
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp"); // alert 띄워주는 공통 JSP
            
        } else {
            // GET 방식으로 들어오면 튕겨냄
            String message = "잘못된 접근입니다.";
            String loc = "javascript:history.back()";
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
        }
    }
}