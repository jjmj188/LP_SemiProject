package order.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;

public class CartUpdate extends AbstractController {

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

        String cartnoStr = request.getParameter("cartno");
        String qtyStr = request.getParameter("qty");

        int cartno;
        int qty;

        try {
            cartno = Integer.parseInt(cartnoStr);
            qty = Integer.parseInt(qtyStr);

            if (cartno <= 0) throw new NumberFormatException();
            if (qty < 1) qty = 1;
        }
        catch (Exception e) {
            request.setAttribute("message", "잘못된 요청입니다.");
            request.setAttribute("loc", "javascript:history.back()");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 1: 정상, 2: 재고로 조정, 0: 실패
        int status = cdao.updateCartQty(loginuserid, cartno, qty);

        if (status == 1) {
            request.setAttribute("message", "수량이 변경되었습니다.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }
        else if (status == 2) {
            request.setAttribute("message", "재고 수량을 초과하여 가능한 수량으로 자동 조정되었습니다.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        request.setAttribute("message", "수량 변경에 실패했습니다.");
        request.setAttribute("loc", "javascript:history.back()");
        setRedirect(false);
        setViewPage("/WEB-INF/msg.jsp");
    }
}
