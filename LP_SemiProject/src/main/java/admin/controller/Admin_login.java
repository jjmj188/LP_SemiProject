package admin.controller;

import java.util.HashMap;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import admin.model.AdminDAO;
import admin.model.AdminVO;
import util.security.Sha256; 

public class Admin_login extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        
        if("GET".equalsIgnoreCase(method)) {
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/admin/admin_login.jsp");
        }
        else {
            String adminid = request.getParameter("adminid");
            String adminpwd = request.getParameter("adminpwd");
            
            String encryptedPwd = Sha256.encrypt(adminpwd);
           
            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("adminid", adminid);
            paraMap.put("adminpwd", encryptedPwd);
            
            AdminDAO adao = new AdminDAO();
            AdminVO loginAdmin = adao.getAdminLogin(paraMap);
            
            if(loginAdmin != null) {
                HttpSession session = request.getSession();
                session.setAttribute("loginAdmin", loginAdmin);
                
                super.setRedirect(true);
                super.setViewPage(request.getContextPath() + "/admin/admin_member.lp");
            }
            else {
                String message = "아이디 또는 비밀번호가 일치하지 않습니다.";
                String loc = "javascript:history.back()";
                
                request.setAttribute("message", message);
                request.setAttribute("loc", loc);
                
                super.setRedirect(false);
                super.setViewPage("/WEB-INF/msg.jsp");
            }
        }
    }
}