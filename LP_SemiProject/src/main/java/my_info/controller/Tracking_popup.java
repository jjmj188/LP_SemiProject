package my_info.controller;

import java.io.PrintWriter;

import org.json.JSONObject;

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

    private boolean isAjax(HttpServletRequest request) {
        String xhr = request.getHeader("X-Requested-With");
        return "XMLHttpRequest".equalsIgnoreCase(xhr);
    }

    private void writeJson(HttpServletResponse response, boolean ok, String msg) throws Exception {
        response.reset();
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        JSONObject json = new JSONObject();
        json.put("ok", ok);
        json.put("msg", msg);

        try (PrintWriter out = response.getWriter()) {
            out.print(json.toString());
            out.flush();
        }
    }

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        boolean ajax = isAjax(request);

        if (loginuser == null) {
            if (ajax) {
                writeJson(response, false, "로그인 후 이용 가능합니다.");
                return;
            }
            request.setAttribute("message", "로그인 후 이용 가능합니다.");
            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String ordernoStr = request.getParameter("orderno");
        int orderno;

        try {
            orderno = Integer.parseInt(ordernoStr);
        } catch (Exception e) {
            if (ajax) {
                writeJson(response, false, "주문번호가 올바르지 않습니다.");
                return;
            }
            request.setAttribute("message", "주문번호가 올바르지 않습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        // 배송/송장 정보 조회
        OrderDTO odto = odao.selectTrackingInfo(orderno, userid);

        if (odto == null) {
            if (ajax) {
                writeJson(response, false, "배송 정보를 찾을 수 없습니다.");
                return;
            }
            request.setAttribute("message", "배송 정보를 찾을 수 없습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_order.lp");
            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        request.setAttribute("odto", odto);

        // 뷰 분기
        setRedirect(false);
        if (ajax) {
            //모달 본문용
            setViewPage("/WEB-INF/my_info/tracking_popup.jsp");
        } else {
            //직접 주소로 접근했을 때는 예전 팝업 화면 사용 가능
            setViewPage("/WEB-INF/my_info/tracking_popup.jsp");
        }
    }
}
