package login.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class Logout extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		 // 1. 세션 가져오기
        HttpSession session = request.getSession(false);

        if (session != null) {
            // 2. 로그인 정보 제거 (또는 세션 전체 종료)
            session.invalidate();
        }

        // 3. 메인 페이지로 이동
        setRedirect(true);
        setViewPage(request.getContextPath() + "/index.lp");
    }

}

