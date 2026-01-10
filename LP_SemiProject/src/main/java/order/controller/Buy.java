package order.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.CartDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;

public class Buy extends AbstractController {

    private CartDAO cdao = new CartDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        // 0) 로그인 체크
        if (loginuser == null) {
            request.setAttribute("message", "로그인 후 이용 가능합니다.");
            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String method = request.getMethod();

        // 1) GET 차단 (장바구니에서 POST로만 들어오게)
        if (!"POST".equalsIgnoreCase(method)) {
            request.setAttribute("message", "잘못된 접근입니다.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 2) 선택한 cartno 배열 받기
        String[] cartnoArr = request.getParameterValues("cartno");

        if (cartnoArr == null || cartnoArr.length == 0) {
            request.setAttribute("message", "주문할 상품을 선택해주세요.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 3) 선택 cartno들에 해당하는 장바구니 목록 조회 (userid 조건 포함)
        String userid = loginuser.getUserid();
        List<CartDTO> cartList = cdao.selectCartListByCartnoArr(userid, cartnoArr);

        if (cartList == null || cartList.size() == 0) {
            request.setAttribute("message", "선택한 상품 정보를 찾을 수 없습니다.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 4) 합계 계산(서버 기준)
        int sumQty = 0;
        int sumTotalPrice = 0;
        int sumTotalPoint = 0;

        for (CartDTO dto : cartList) {
            sumQty += dto.getQty();
            sumTotalPrice += dto.getTotalPrice();
            sumTotalPoint += dto.getTotalPoint();
        }

        int discountAmount = 0;
        int deliveryFee = 3000;
        int finalPayAmount = (sumTotalPrice - discountAmount) + deliveryFee;

        // 5) buy.jsp로 전달
        request.setAttribute("cartList", cartList);
        request.setAttribute("sumQty", sumQty);
        request.setAttribute("sumTotalPrice", sumTotalPrice);
        request.setAttribute("sumTotalPoint", sumTotalPoint);
        request.setAttribute("discountAmount", discountAmount);
        request.setAttribute("deliveryFee", deliveryFee);
        request.setAttribute("finalPayAmount", finalPayAmount);

        // ✅ pay로 넘기기 위한 선택 cartno 보관
        request.setAttribute("cartnoArr", cartnoArr);

        setRedirect(false);
        setViewPage("/WEB-INF/order/buy.jsp");
    }
}
