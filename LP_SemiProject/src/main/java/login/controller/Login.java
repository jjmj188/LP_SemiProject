package login.controller;

import java.util.HashMap;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.Cookie;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class Login extends AbstractController {

    private MemberDAO mdao = new MemberDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String method = request.getMethod(); // GET / POST
         
        // 0. 이미 로그인된 사용자가 접근할 경우 메인으로 이동
        HttpSession session = request.getSession();
        MemberDTO loginuser_session = (MemberDTO) session.getAttribute("loginuser");
        Boolean isLogin = (Boolean) session.getAttribute("isLogin");

        //로그인값이 null이 아니고 로그인값이 참일 경우에는 메인으로 이동
        if (loginuser_session != null && isLogin != null && isLogin) {
            setRedirect(true);
            setViewPage(request.getContextPath() + "/index.lp");
            return; 
        }
        
        if ("GET".equalsIgnoreCase(method)) {
            setRedirect(false);
            setViewPage("/WEB-INF/login/login.jsp");
            return;
        }

        // ===== POST =====
        String userid = request.getParameter("userid");
        String pwd = request.getParameter("pwd");
        String saveid = request.getParameter("saveid");

        // 클라이언트 IP 현재 요청을 보낸 사용자의 IP 주소를 문자열로 반환
        String clientip = request.getRemoteAddr();

        Map<String, String> paraMap = new HashMap<>();
        paraMap.put("userid", userid);
        paraMap.put("pwd", pwd);
        paraMap.put("clientip", clientip);

           //  1. 로그인 시도
        MemberDTO loginuser = mdao.login(paraMap);

        if (loginuser != null) {
        	
            //  2. 휴면 판정 
        	if(loginuser.getIdle() == 1 || loginuser.getLastLoginGap() >= 12) {
            	
        		// [휴면 상태]->idle_release로 이동 
                // 객체 전체(loginuser)를 세션에 담지 않고 아이디만 저장합니다.
                session.setAttribute("idle_userid", userid);
                session.setAttribute("isLogin", false);
               
                if(loginuser.getIdle()==0) {
                mdao.updateIdle(userid);
                }
                
                setRedirect(true);
                setViewPage(request.getContextPath() + "/login/idle_release.lp");
                return;
            }

            //  3. 정상 로그인 → 로그인 기록 INSERT
            mdao.insertLoginHistory(userid, clientip);

            //  4. 아이디 저장 쿠키
            if (saveid != null) {
                Cookie cookie = new Cookie("saveid", userid);
                cookie.setMaxAge(24 * 60 * 60); // 1일
                cookie.setPath("/");
                response.addCookie(cookie);
            } else {
                Cookie cookie = new Cookie("saveid", null);
                cookie.setMaxAge(0);
                cookie.setPath("/");
                response.addCookie(cookie);
            }

            //  5. 세션 저장
          
            session.setAttribute("loginuser", loginuser);
            session.setAttribute("isLogin", true);

            //  6. 로그인 성공 후 비밀번호 변경 안내
            if (loginuser.isRequirePwdChange()) {

            	String message = "비밀번호를 변경하신지 3개월이 지났습니다.\\n비밀번호 변경 페이지로 이동합니다.";
                String loc = request.getContextPath() + "/login/pwd_change.lp";

                request.setAttribute("message", message);
                request.setAttribute("loc", loc);

                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }

            // 7. 로그인 성공 → 메인
            setRedirect(true);
            setViewPage(request.getContextPath() + "/index.lp");
        }
        else {
            // 로그인 실패
            String message = "아이디 및 비밀번호를 확인해주세요.";
            String loc = "javascript:history.back()";

            request.setAttribute("message", message);
            request.setAttribute("loc", loc);

            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
        }
    }
}
