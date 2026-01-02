package member.controller;

import java.sql.SQLException;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class MemberRegister extends AbstractController {

	private MemberDAO mdao = new MemberDAO_imple();
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String method = request.getMethod(); // "GET" 또는 "POST"
		
		if("GET".equalsIgnoreCase(method)) {
			super.setRedirect(false);
			super.setViewPage("/WEB-INF/member/member_register.jsp");	
		}
		
		else {
			String name = request.getParameter("name");
			String userid = request.getParameter("userid");
			String pwd = request.getParameter("pwd");
			String email = request.getParameter("email");
			String hp1 = request.getParameter("hp1");
			String hp2 = request.getParameter("hp2");
			String hp3 = request.getParameter("hp3");
			String gender = request.getParameter("gender");
			String birthday = request.getParameter("birthday");
			
			String mobile = hp1+hp2+hp3;
			
			MemberDTO member = new MemberDTO();
			member.setUserid(userid);
			member.setPwd(pwd);
			member.setName(name);
			member.setEmail(email);
			member.setMobile(mobile);
			member.setGender(gender);
			member.setBirthday(birthday);
			
		 // ==== 회원가입이 성공되어지면 "회원가입 성공" 이라는 alert 를 띄우고 시작페이지로 이동한다. ==== //
			String message = "";
			String loc = "";
			
			try {
				int n = mdao.registerMember(member);
				if(n==1) {
					
					 HttpSession session = request.getSession();
					 session.setAttribute("userid", member.getUserid());
					
					message = "회원가입 성공^^";
					loc = request.getContextPath()+"/member/taste_check.lp"; 
				}
			} catch(SQLException e) {
				e.printStackTrace();
				
				message = "회원가입 실패ㅜㅜ";
				loc = "javascript:history.back()"; // 자바스크립트를 이용한 이전페이지로 이동하는 것.
			}
			
			request.setAttribute("message", message);
			request.setAttribute("loc", loc);
			
			super.setRedirect(false);
			super.setViewPage("/WEB-INF/msg.jsp");
		}
		
	}

}


