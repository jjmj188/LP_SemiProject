package order.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;

public class CartDeleteAll extends AbstractController {

    private CartDAO cdao = new CartDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            request.setAttribute("message", "로그인 후 이용 가능합니다.");
            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            request.setAttribute("message", "잘못된 접근입니다.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        int deletedCount = cdao.deleteAll(userid);

        request.setAttribute("message", "장바구니 상품 " + deletedCount + "개를 전체 삭제했습니다.");
        request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
        setRedirect(false);
        setViewPage("/WEB-INF/msg.jsp");
    }
}
