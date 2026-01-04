package member.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class TasteCheck extends AbstractController {

    private MemberDAO mdao = new MemberDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

         //1️ 로그인 체크
        if (loginuser == null) {
            setRedirect(true);
            setViewPage(request.getContextPath() + "/login/login.lp");
            return;
        }

        String method = request.getMethod();

        // 2️ GET → 취향 선택 화면
        if ("GET".equalsIgnoreCase(method)) {
            setRedirect(false);
            setViewPage("/WEB-INF/member/taste_check.jsp");
            return;
        }

        // 3️ POST → 취향 저장
        String categoryList = request.getParameter("categoryList");

        if (categoryList == null || categoryList.trim().isEmpty()) {
            request.setAttribute("message", "취향은 1개 이상 선택해야 합니다.");
            request.setAttribute("loc", "javascript:history.back()");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String[] arr = categoryList.split(",");
        String userid = loginuser.getUserid();

        int n = mdao.insertTaste(userid, arr);

        if (n > 0) {
            setRedirect(true);
            setViewPage(request.getContextPath() + "/index.lp");
        } else {
            request.setAttribute("message", "취향 저장에 실패했습니다.");
            request.setAttribute("loc", "javascript:history.back()");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
        }
    }
}
