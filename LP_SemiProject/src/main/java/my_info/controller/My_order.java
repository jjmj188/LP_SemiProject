package my_info.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.OrderDTO;
import order.domain.OrderDetailDTO;
import order.model.OrderDAO;
import order.model.OrderDAO_imple;

public class My_order extends AbstractController {

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

        String userid = loginuser.getUserid();

        // 1) 주문 카드 목록
        List<OrderDTO> orderList = odao.selectMyOrderList(userid);

        // 2) 각 주문마다 "그 주문의 상세"만 붙이기
        if (orderList != null) {
            for (OrderDTO o : orderList) {
                List<OrderDetailDTO> detailList = odao.selectMyOrderDetailList(o.getOrderno(), userid);
                o.setOrderDetailList(detailList);
            }
        }

        request.setAttribute("orderList", orderList);

        setRedirect(false);
        setViewPage("/WEB-INF/my_info/my_order.jsp");
    }
}
