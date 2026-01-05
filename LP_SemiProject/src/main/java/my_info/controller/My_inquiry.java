package my_info.controller;

import java.sql.SQLException;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.InquiryDAO;
import member.model.InquiryDAO_imple;


public class My_inquiry extends AbstractController {

	private InquiryDAO mpdao = new InquiryDAO_imple();

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String method = request.getMethod();

		
		
		if ("GET".equalsIgnoreCase(method)) {

			super.setRedirect(false);
			super.setViewPage("/WEB-INF/my_info/my_inquiry.jsp");
		}

		else {

			HttpSession session = request.getSession();
			MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

			// 로그인 안 된 경우 차단
			if (loginuser == null) {
				super.setRedirect(true);
				super.setViewPage(request.getContextPath() + "/login/login.lp");
				return;
			}

			String userid = loginuser.getUserid();
			String inquirycontent = request.getParameter("inquirycontent");

			String message = "";
			String loc = "";

			try {
				int n = mpdao.insertInquiry(userid, inquirycontent);
				
				if (n == 1) {
					message = "문의가 정상적으로 접수되었습니다.";
					loc = request.getContextPath() + "/my_info/my_inquiry.lp";
				}
				else {
					message = "문의 등록에 실패했습니다.";
					loc = "javascript:history.back()";
				}

			} catch (SQLException e) {
				e.printStackTrace();
				message = "서버 오류로 문의 등록에 실패했습니다.";
				loc = "javascript:history.back()";
			}

			request.setAttribute("message", message);
			request.setAttribute("loc", loc);

			super.setRedirect(false);
			super.setViewPage("/WEB-INF/msg.jsp");
		}
	}
}
