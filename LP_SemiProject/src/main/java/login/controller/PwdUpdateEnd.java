package login.controller;

import java.sql.SQLException;
import java.util.HashMap;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class PwdUpdateEnd extends AbstractController {

	private MemberDAO mdao = new MemberDAO_imple();
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		// 1. 유저 아이디와 전송 방식 확인
        String userid = request.getParameter("userid");
        String method = request.getMethod(); // "GET" 또는 "POST" 
        
        if("POST".equalsIgnoreCase(method)) {
            // 2. 사용자가 입력한 새 비밀번호 가져오기
            String new_pwd = request.getParameter("pwd");
            
            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("userid", userid);
            paraMap.put("new_pwd", new_pwd);
            
            int n = 0;
            try {
                // 3. DAO 호출 (여기서 -1, 0, 1 중 하나가 리턴됨)
                n = mdao.pwdUpdate(paraMap);
            } catch(SQLException e) {
                e.printStackTrace();
                n = 0; // 에러 발생 시 실패 처리
            }
            
            // 4. 처리 결과를 request에 담아서 JSP로 보냄
            request.setAttribute("n", n);
        }
        
        request.setAttribute("method", method);
        request.setAttribute("userid", userid);
        
        // 5. 뷰 페이지 설정 (forward 방식)
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/login/pwd_updateEnd.jsp");
    }


}
