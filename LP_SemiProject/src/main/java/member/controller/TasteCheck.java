package member.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class TasteCheck extends AbstractController {
	private MemberDAO mdao = new MemberDAO_imple();
    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
System.out.println("들어옴");
        HttpSession session = request.getSession();
        String userid = (String) session.getAttribute("userid");
     // 1. 로그인 체크 (세션에 아이디가 없으면 쫓아냄)
        if(userid == null) {
            setRedirect(true);
            setViewPage(request.getContextPath() + "/login/login.lp");
            return;
        }

        String method = request.getMethod(); // GET 또는 POST

        if("GET".equalsIgnoreCase(method)) {
            // [GET 방식] 단순히 취향 선택 화면(JSP)을 보여주는 기능
            setRedirect(false);
            setViewPage("/WEB-INF/member/taste_check.jsp"); // JSP 위치에 맞게 수정
            return;
        }

        String categoryList = request.getParameter("categoryList");

        if(categoryList == null || categoryList.trim().isEmpty()) {

            request.setAttribute("message", "취향은 1개 이상 선택해야 합니다.");
            request.setAttribute("loc", "javascript:history.back()");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String[] arr = categoryList.split(",");

       
        int n=mdao.insertTaste(userid, arr);
        
        if(n==1) {
        	// 저장 후 메인
            setRedirect(true);
            setViewPage(request.getContextPath() + "/main.lp");	
        }else {
        	// 저장 실패 시 처리
            request.setAttribute("message", "취향 저장에 실패했습니다.");
            request.setAttribute("loc", "javascript:history.back()");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
        }
        
        

		
        
	}//public class TasteCheck extends AbstractController

}//end 
