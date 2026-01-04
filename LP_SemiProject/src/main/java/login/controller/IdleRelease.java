package login.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class IdleRelease extends AbstractController {
    
    private MemberDAO mdao = new MemberDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
    	
        
    	String method = request.getMethod(); // GET 또는 POST
        HttpSession session = request.getSession();
        Boolean isLogin = (Boolean) session.getAttribute("isLogin");
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
    
        // 1️ 세션 체크 
        if (loginuser == null) {
            request.setAttribute("message", "잘못된 접근입니다. 로그인을 먼저 하세요.");
            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 2️ GET 방식: 비밀번호 변경(휴면해제) 화면 보여주기
        if ("GET".equalsIgnoreCase(method)) {
        	super.setRedirect(false);
            super.setViewPage("/WEB-INF/login/idle_release.jsp"); 
            return; 
        }

        // 3️ POST 방식: 실제 비밀번호 변경 로직 수행
        if ("POST".equalsIgnoreCase(method)) {
            
            String userid = loginuser.getUserid();
            String newPwd = request.getParameter("newPwd");
            String newPwdCheck = request.getParameter("newPwdCheck");

            // 서버측 유효성 검증
            if (newPwd == null || newPwd.trim().isEmpty() || !newPwd.equals(newPwdCheck)) {
                request.setAttribute("message", "비밀번호가 일치하지 않거나 입력되지 않았습니다.");
                request.setAttribute("loc", "javascript:history.back()");
                
                super.setRedirect(false);
                super.setViewPage("/WEB-INF/msg.jsp");
                return;
            }

            String clientip = request.getRemoteAddr();
            int result = mdao.changePassword(userid, newPwd, clientip);
            
            String message = "";
            String loc = "";

            if (result == -1) {
                message = "기존 비밀번호와 동일한 비밀번호는 사용할 수 없습니다.";
                loc = "javascript:history.back()";
            } 
            else if (result == 1) {
                // 성공 시 세션 정보 동기화
                loginuser.setIdle(0); 
                loginuser.setRequirePwdChange(false);
                session.setAttribute("loginuser", loginuser);
                session.setAttribute("isLogin", true);
                
                message = "비밀번호가 성공적으로 변경되어 휴면 상태가 해제되었습니다.";
                loc = request.getContextPath() + "/index.lp";
            } 
            else {
                message = "비밀번호 변경에 실패했습니다. 다시 시도해주세요.";
                loc = "javascript:history.back()";
            }

            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
        }
    }
}