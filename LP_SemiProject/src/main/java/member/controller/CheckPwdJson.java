package member.controller;

import org.json.JSONObject;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class CheckPwdJson extends AbstractController {
    private MemberDAO mdao = new MemberDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        String pwd = request.getParameter("pwd");
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        // DB 확인
        boolean isMatch = mdao.checkPassword(loginuser.getUserid(), pwd);

        // JSON 응답 생성
        JSONObject jsonObj = new JSONObject();
        jsonObj.put("isMatch", isMatch);

        String json = jsonObj.toString();
        request.setAttribute("json", json);

        this.setRedirect(false);
        this.setViewPage("/WEB-INF/jsonview.jsp"); // 결과값만 출력할 공통 JSP
    }
}