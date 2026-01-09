package my_info.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class My_taste extends AbstractController {
	private MemberDAO mdao = new MemberDAO_imple();
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String method=request.getMethod();
		HttpSession session=request.getSession();
		MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
		  
		//로그인 확인 
		if (loginuser == null) {
	            request.setAttribute("message", "로그인이 필요합니다.");
	            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
	            setRedirect(false);
	            setViewPage("/WEB-INF/msg.jsp");
	            return;
	        }
		if ("GET".equalsIgnoreCase(method)) {
	        // 1. 단순 페이지 이동 (취향 선택 화면 보여주기)
			
			List<Integer> prefList = mdao.getUserPreference(loginuser.getUserid());
            request.setAttribute("prefList", prefList);
			
	        setRedirect(false);
	        setViewPage("/WEB-INF/my_info/my_taste.jsp"); // JSP 경로 확인 필요
	    } else {
	    
	    	
	    	
	    String categoryList=request.getParameter("categoryList");
		
		if(categoryList==null ||categoryList.trim().isEmpty()) {
			 request.setAttribute("message", "취향을 선택해주세요.");
			 request.setAttribute("loc", "javascript:history.back()");
			 setRedirect(false);
             setViewPage("/WEB-INF/msg.jsp");
             return;
		}
		
		
		String[]categoryArr=categoryList.split(",");
		boolean isSuccess=mdao.updateMemberPreference(loginuser.getUserid(),categoryArr);
		
		if (isSuccess) {
		    request.setAttribute("message", "취향이 수정되었습니다 🎧");
		    request.setAttribute("loc", request.getContextPath() + "/my_info/my_taste.lp");
		} else {
		    request.setAttribute("message", "취향 저장에 실패했습니다.");
		    request.setAttribute("loc", "javascript:history.back()");
		}

		setRedirect(false);
		setViewPage("/WEB-INF/msg.jsp");
	    }
	}

}
