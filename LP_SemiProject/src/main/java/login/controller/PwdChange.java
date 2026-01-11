package login.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class PwdChange extends AbstractController {
	private MemberDAO mdao = new MemberDAO_imple();
	@Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod(); // GET 또는 POST
        
        // 1. 로그인 여부 체크 (가장 먼저 수행)
        HttpSession session = request.getSession(false);
        if (session == null || session.getAttribute("loginuser") == null) {
            request.setAttribute("message", "로그인이 필요한 서비스입니다.");
            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 2. GET 방식일 때 (비밀번호 변경 페이지 보여주기)
        if ("GET".equalsIgnoreCase(method)) {
            setRedirect(false);
            setViewPage("/WEB-INF/login/pwd_change.jsp");
            return;
        }

        // 3. POST 방식일 때 (실제 비밀번호 변경 처리)
        if ("POST".equalsIgnoreCase(method)) {
            
            MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
            
            // 파라미터 받기
            String userid = loginuser.getUserid();
            String newPwd = request.getParameter("newPwd");
            String newPwdCheck = request.getParameter("newPwdCheck");

            // 서버측 최소 검증
            if (newPwd == null || newPwdCheck == null || !newPwd.equals(newPwdCheck)) {
                request.setAttribute("message", "비밀번호가 일바르지 않거나 일치하지 않습니다.");
                request.setAttribute("loc", "javascript:history.back()");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }

            String clientip = request.getRemoteAddr();
            int result = mdao.changePassword(userid, newPwd, clientip);
            
            if(result == -1) {
                request.setAttribute("message", "기존 비밀번호와 동일한 비밀번호는 사용할 수 없습니다.");
                request.setAttribute("loc", "javascript:history.back()");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            } else if(result == 1) {
                // 변경 성공 시 세션 정보 업데이트
                loginuser.setRequirePwdChange(false);
                loginuser.setIdle(0);
                session.setAttribute("loginuser", loginuser);
                
                request.setAttribute("message", "비밀번호가 성공적으로 변경되었습니다.");
                request.setAttribute("loc", request.getContextPath() + "/index.lp");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            } else {
                request.setAttribute("message", "비밀번호 변경에 실패했습니다. 다시 시도해주세요.");
                request.setAttribute("loc", "javascript:history.back()");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }
        }

    }
}
