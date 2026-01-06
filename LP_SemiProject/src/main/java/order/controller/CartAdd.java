package order.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;

public class CartAdd extends AbstractController {

	private CartDAO cdao = new CartDAO_imple();

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String method = request.getMethod();
		HttpSession session = request.getSession();
		MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

		// 로그인 체크
		if (loginuser == null) {
			request.setAttribute("message", "로그인 후 이용 가능합니다.");
			request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
			setRedirect(false);
			setViewPage("/WEB-INF/msg.jsp");
			return;
		}

		// POST만 허용
		if (!"POST".equalsIgnoreCase(method)) {
			request.setAttribute("message", "잘못된 접근입니다.");
			request.setAttribute("loc", "javascript:history.back()");
			setRedirect(false);
			setViewPage("/WEB-INF/msg.jsp");
			return;
		}

		String loginuserid = loginuser.getUserid();

		
		String productnoStr = request.getParameter("productno");
		String qtyStr = request.getParameter("qty");

		int productno;
		int qty;

		try {
			productno = Integer.parseInt(productnoStr);
			qty = Integer.parseInt(qtyStr);

			if (productno <= 0) throw new NumberFormatException();
			if (qty < 1) qty = 1;
		}
		catch (Exception e) {
			request.setAttribute("message", "잘못된 요청입니다.");
			request.setAttribute("loc", "javascript:history.back()");
			setRedirect(false);
			setViewPage("/WEB-INF/msg.jsp");
			return;
		}

		
		int n = cdao.addCart(loginuserid, productno, qty);

		if (n == 1) {
			request.setAttribute("message", "장바구니에 담겼습니다.");
			request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
			setRedirect(false);
			setViewPage("/WEB-INF/msg.jsp");
			return;
		}

		// 실패
		request.setAttribute("message", "장바구니 담기에 실패했습니다.");
		request.setAttribute("loc", "javascript:history.back()");
		setRedirect(false);
		setViewPage("/WEB-INF/msg.jsp");
	}
}
