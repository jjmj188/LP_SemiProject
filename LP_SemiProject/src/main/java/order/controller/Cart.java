package order.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.CartDTO;
import order.model.*;

public class Cart extends AbstractController {

	private CartDAO cdao = new CartDAO_imple();
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String method = request.getMethod();
		HttpSession session = request.getSession();
		MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
		
		if(loginuser == null) {
			 request.setAttribute("message", "로그인 후 이용 가능합니다.");
	         request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
	         setRedirect(false);
	         setViewPage("/WEB-INF/msg.jsp");
	         return;
		}
		
		// GET 직접 접근 차단
		String referer = request.getHeader("referer");

		if (referer == null) {

		    request.setAttribute("message", "잘못된 접근입니다.");
		    request.setAttribute("loc", request.getContextPath() + "/index.lp");

		    super.setRedirect(false);
		    super.setViewPage("/WEB-INF/msg.jsp");
		    return;
		}

	
		String userid = loginuser.getUserid();
		
		//장바구니 조회
		List<CartDTO> cartList = cdao.selectCartList(userid);
		
		
		//총 가격, 포인트
		int sumTotalPrice = 0;
		int sumTotalPoint = 0;
		
		if (cartList != null) {
			for (CartDTO dto : cartList) {
	            sumTotalPrice += dto.getTotalPrice();
	            sumTotalPoint += dto.getTotalPoint();
	        }
		}
		
		
		
		request.setAttribute("cartList", cartList);
		request.setAttribute("sumTotalPrice", sumTotalPrice);
		request.setAttribute("sumTotalPoint", sumTotalPoint);
		
		setRedirect(false);
	    setViewPage("/WEB-INF/order/cart.jsp");
		
	}

}
