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

    private boolean isAjax(HttpServletRequest request) {
        String v = request.getHeader("X-Requested-With");
        return v != null && "XMLHttpRequest".equalsIgnoreCase(v);
    }

    private void writeJson(HttpServletResponse response, boolean ok, String msg) throws Exception {
        response.reset();
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        String safeMsg = (msg == null) ? "" : msg.replace("\\", "\\\\").replace("\"", "\\\"");
        response.getWriter().write("{\"ok\":" + ok + ",\"msg\":\"" + safeMsg + "\"}");
    }

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            if (isAjax(request)) {
                writeJson(response, false, "로그인 후 이용 가능합니다.");
                return;
            }
            request.setAttribute("message", "로그인 후 이용 가능합니다.");
            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String strOrderno = request.getParameter("orderno");
        String strProductno = request.getParameter("productno");

        int orderno, productno;

        try {
            orderno = Integer.parseInt(strOrderno);
            productno = Integer.parseInt(strProductno);
        } catch (Exception e) {
            if (isAjax(request)) {
                writeJson(response, false, "잘못된 접근입니다.");
                return;
            }
            request.setAttribute("message", "잘못된 접근입니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        // 구매 검증 + 표시 정보 조회
        OrderDetailDTO item = rdao.selectOrderItemForReview(userid, orderno, productno);
        if (item == null) {
            if (isAjax(request)) {
                writeJson(response, false, "구매한 상품만 리뷰를 작성할 수 있습니다.");
                return;
            }
            request.setAttribute("message", "구매한 상품만 리뷰를 작성할 수 있습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 이미 리뷰 작성했으면 막기
        if (rdao.existsReview(userid, productno, orderno)) {
            if (isAjax(request)) {
                writeJson(response, false, "이미 작성한 리뷰입니다.");
                return;
            }
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

        if (isAjax(request)) {
            setViewPage("/WEB-INF/my_info/review_write.jsp");
        } else {
            
            setViewPage("/WEB-INF/my_info/review_write.jsp");
        }
    }
}
