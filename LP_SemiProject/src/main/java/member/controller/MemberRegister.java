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
		 HttpSession session = request.getSession();
		    MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

		    if (loginuser != null) { 
		        request.setAttribute("message", "이미 로그인된 상태이므로 회원가입을 하실 수 없습니다.");
		        request.setAttribute("loc", request.getContextPath() + "/index.lp");

		        super.setRedirect(false);
		        super.setViewPage("/WEB-INF/msg.jsp");
		        return; 
		    }
		    
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
			String postcode = request.getParameter("postcode");
			String address = request.getParameter("address");
			String detailaddress = request.getParameter("detailaddress");
			String extraaddress = request.getParameter("extraaddress");
			
			String mobile = hp1+hp2+hp3;
			
			MemberDTO member = new MemberDTO();
			member.setUserid(userid);
			member.setPwd(pwd);
			member.setName(name);
			member.setEmail(email);
			member.setMobile(mobile);
			member.setGender(gender);
			member.setBirthday(birthday);
			member.setPostcode(postcode);
			member.setAddress(address);
			member.setDetailaddress(detailaddress);
			member.setExtraaddress(extraaddress);
			
		 // ==== 회원가입이 성공되어지면 "회원가입 성공" 이라는 alert 를 띄우고 시작페이지로 이동한다. ==== //
			String message = "";
			String loc = "";
			
			try {
				int n = mdao.registerMember(member);
				if(n==1) {
					
				    // 2. 로그인과 동일한 '객체'와 '키값'으로 세션 저장 
				    // 가입할 때 사용한 member 객체(MemberDTO)를 그대로 활용합니다.
				    session.setAttribute("loginuser", member); 
				 
				    // 2-1 로그인 상태임을 증명하는 플래그 저장 
				    session.setAttribute("isLogin", true);
				    // 3. 로그인 기록 남기기
				    String clientip = request.getRemoteAddr();
				    mdao.insertLoginHistory(member.getUserid(), clientip);
				    
					message = "회원가입을 축하드립니다.";
					loc = request.getContextPath()+"/member/taste_check.lp"; // 취향체크 페이지로 이동한다.
					
					
				    setRedirect(true); 
				    setViewPage(loc);
				    return; 
				}
			} catch(SQLException e) {
				e.printStackTrace();
				
				message = "회원가입 실패";
				loc = "javascript:history.back()"; // 자바스크립트를 이용한 이전페이지로 이동하는 것.
			}
			
			request.setAttribute("message", message);
			request.setAttribute("loc", loc);
			
			super.setRedirect(false);
			super.setViewPage("/WEB-INF/msg.jsp");
		}
		
	}

}


