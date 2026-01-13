package order.controller;

import java.util.ArrayList;
import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.CartDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;
import product.domain.ProductDTO;
import product.model.ProductDAO;
import product.model.ProductDAO_imple;

public class Buy extends AbstractController {

    private CartDAO cdao = new CartDAO_imple();
    private ProductDAO pdao = new ProductDAO_imple(); // ✅ 바로구매용: 상품정보 조회

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

        String method = request.getMethod();
        if (!"POST".equalsIgnoreCase(method)) {
            request.setAttribute("message", "잘못된 접근입니다.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        // 장바구니 구매(cartno[])인지, 바로구매(productno/qty)인지 분기
        String[] cartnoArr = request.getParameterValues("cartno");
        String productnoStr = request.getParameter("productno");
        String qtyStr = request.getParameter("qty");

        List<CartDTO> cartList = null;

        
        // 장바구니 구매
       
        if (cartnoArr != null && cartnoArr.length > 0) {

            cartList = cdao.selectCartListByCartnoArr(userid, cartnoArr);

            if (cartList == null || cartList.size() == 0) {
                request.setAttribute("message", "선택한 상품 정보를 찾을 수 없습니다.");
                request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }

            request.setAttribute("cartnoArr", cartnoArr);
        }
        // 바로구매 (상품상세에서 productno, qty로 옴)
        else if (productnoStr != null && qtyStr != null && !"".equals(productnoStr.trim()) && !"".equals(qtyStr.trim())) {

            int productno = 0;
            int qty = 1;

            try {
                productno = Integer.parseInt(productnoStr);
                qty = Integer.parseInt(qtyStr);
            } catch (NumberFormatException e) {
                request.setAttribute("message", "요청 값이 올바르지 않습니다.");
                request.setAttribute("loc", request.getContextPath() + "/");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }

            if (qty < 1) qty = 1;

            //서버에서 상품 조회
            ProductDTO pDto = pdao.selectOneProduct(productno);

            if (pDto == null) {
                request.setAttribute("message", "상품 정보를 찾을 수 없습니다.");
                request.setAttribute("loc", request.getContextPath() + "/");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }

          //재고체크
            if (qty > pDto.getStock()) {
                request.setAttribute("message", "재고가 부족합니다. 현재 재고: " + pDto.getStock());
                request.setAttribute("loc", "javascript:history.back()");
                setRedirect(false);
                setViewPage("/WEB-INF/msg.jsp");
                return;
            }

           
            CartDTO dto = new CartDTO();
            dto.setUserid(userid);

            dto.setProductno(pDto.getProductno());
            dto.setProductname(pDto.getProductname());
            dto.setProductimg(pDto.getProductimg());
            dto.setPrice(pDto.getPrice());
            dto.setPoint(pDto.getPoint());
            dto.setQty(qty);

            // 합계
            dto.setTotalPrice(pDto.getPrice() * qty);
            dto.setTotalPoint(pDto.getPoint() * qty);

            cartList = new ArrayList<>();
            cartList.add(dto);

            request.setAttribute("isDirectBuy", true);
        }
   
        else {
            request.setAttribute("message", "주문할 상품을 선택해주세요.");
            request.setAttribute("loc", request.getContextPath() + "/order/cart.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        //합계 계산
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

        request.setAttribute("cartList", cartList);
        request.setAttribute("sumQty", sumQty);
        request.setAttribute("sumTotalPrice", sumTotalPrice);
        request.setAttribute("sumTotalPoint", sumTotalPoint);
        request.setAttribute("discountAmount", discountAmount);
        request.setAttribute("deliveryFee", deliveryFee);
        request.setAttribute("finalPayAmount", finalPayAmount);

        setRedirect(false);
        setViewPage("/WEB-INF/order/buy.jsp");
    }
}
