package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.OrderDetailDTO;
import product.model.ReviewDAO;
import product.model.ReviewDAO_imple;

public class Review_write extends AbstractController {

    private ReviewDAO rdao = new ReviewDAO_imple();

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

        String strOrderno = request.getParameter("orderno");
        String strProductno = request.getParameter("productno");

        int orderno = 0;
        int productno = 0;

        try {
            orderno = Integer.parseInt(strOrderno);
            productno = Integer.parseInt(strProductno);
        } catch (Exception e) {
            request.setAttribute("message", "잘못된 접근입니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // ✅ 구매 검증 + 표시 정보 조회
        OrderDetailDTO item = rdao.selectOrderItemForReview(loginuser.getUserid(), orderno, productno);

        if (item == null) {
            request.setAttribute("message", "구매한 상품만 리뷰를 작성할 수 있습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // ✅ 이미 리뷰 작성했으면 막기 (fk_orderno 포함)
        boolean already = rdao.existsReview(loginuser.getUserid(), productno, orderno);

        if (already) {
            request.setAttribute("message", "이미 작성한 리뷰입니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        request.setAttribute("orderno", orderno);
        request.setAttribute("productno", productno);
        request.setAttribute("prdName", item.getProductname());
        request.setAttribute("prdImg", item.getProductimg());
        request.setAttribute("price", item.getUnitprice()); 

        setRedirect(false);
        setViewPage("/WEB-INF/my_info/review_write.jsp");
    }
}
