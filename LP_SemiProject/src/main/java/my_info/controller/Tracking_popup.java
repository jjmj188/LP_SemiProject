package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.OrderDTO;
import order.model.OrderDAO;
import order.model.OrderDAO_imple;

public class Tracking_popup extends AbstractController {

    private OrderDAO odao = new OrderDAO_imple();

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
        
        

        String ordernoStr = request.getParameter("orderno");
        int orderno = 0;

        try {
            orderno = Integer.parseInt(ordernoStr);
        } catch (Exception e) {
            request.setAttribute("message", "주문번호가 올바르지 않습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        // 주문주소 + 배송정보(송장) 조회
        OrderDTO odto = odao.selectTrackingInfo(orderno, userid);

        if (odto == null) {
            request.setAttribute("message", "배송 정보를 찾을 수 없습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        request.setAttribute("odto", odto);
        setRedirect(false);
        setViewPage("/WEB-INF/my_info/tracking_popup.jsp");
    }
}
