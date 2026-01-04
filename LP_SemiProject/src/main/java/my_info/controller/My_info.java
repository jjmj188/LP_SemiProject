package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class My_info extends AbstractController {

	private MemberDAO mdao = new MemberDAO_imple();

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String method=request.getMethod();
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
		 if (loginuser == null) {
	            setRedirect(true);
	            setViewPage(request.getContextPath() + "/login/login.lp");
	            return;
	        }
		 /* =====================
	       GET : 페이지 보여주기
	    ===================== */
	    if ("GET".equalsIgnoreCase(method)) {
	        setRedirect(false);
	        setViewPage("/WEB-INF/my_info/my_info.jsp");
	        return;
	    }
		// POST만 허용
		if (!"POST".equalsIgnoreCase(request.getMethod())) {
			setRedirect(true);
			setViewPage(request.getContextPath() + "/login/login.lp");
			return;
		}


		// 회원정보 파라미터
		String userid = loginuser.getUserid();
		String name = request.getParameter("name");
		String email = request.getParameter("email");

		String hp2 = request.getParameter("hp2");
		String hp3 = request.getParameter("hp3");
		String mobile = "010" + hp2 + hp3;
		
		String postcode = request.getParameter("postcode");
        String address = request.getParameter("address");
        String detailaddress = request.getParameter("detailaddress");
        String extraaddress = request.getParameter("extraaddress");
		// DTO에 담기 (회원 컬럼만!)
		MemberDTO member = new MemberDTO();
		member.setUserid(userid);
		member.setName(name);
		member.setEmail(email);
		member.setMobile(mobile);
		member.setPostcode(postcode);
        member.setAddress(address);
        member.setDetailaddress(detailaddress);
        member.setExtraaddress(extraaddress);
		
		// 수정 실행
		int n = mdao.updateMemberInfo(member);

		if (n == 1) {
			// 세션 최신화
			loginuser.setName(name);
			loginuser.setEmail(email);
			loginuser.setMobile(mobile);
		    loginuser.setPostcode(postcode);
            loginuser.setAddress(address);
            loginuser.setDetailaddress(detailaddress);
            loginuser.setExtraaddress(extraaddress);
			
            session.setAttribute("loginuser", loginuser);

			request.setAttribute("message", "회원정보가 수정되었습니다.");
			request.setAttribute("loc", request.getContextPath() + "/my_info/my_info.lp");
		}
		else {
			request.setAttribute("message", "회원정보 수정에 실패했습니다.");
			request.setAttribute("loc", "javascript:history.back()");
		}

		setRedirect(false);
		setViewPage("/WEB-INF/msg.jsp");
	 }
	}

