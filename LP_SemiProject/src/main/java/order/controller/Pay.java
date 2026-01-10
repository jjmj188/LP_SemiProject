package order.controller;

import java.io.BufferedReader;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.CartDTO;
import order.domain.OrderDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;
import order.model.OrderDAO;
import order.model.OrderDAO_imple;

public class Pay extends AbstractController {

    private OrderDAO odao = new OrderDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int n = 0;
        String message = "";
        String loc = "";

        String method = request.getMethod();
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            message = "로그인 후 이용 가능합니다.";
            loc = request.getContextPath() + "/login/login.lp";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", n);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        if (!"POST".equalsIgnoreCase(method)) {
            message = "비정상적인 접근입니다.";
            loc = "history.back()";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", 0);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = request.getReader()) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }

        if (sb.length() == 0) {
            message = "요청 데이터가 비어있습니다.";
            loc = "history.back()";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", n);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        JSONObject body = new JSONObject(sb.toString());

        // payload 값 받기
        String postcode = body.optString("postcode", "").trim();
        String address = body.optString("address", "").trim();
        String detailaddress = body.optString("detailaddress", "").trim();
        String extraaddress = body.optString("extraaddress", "").trim();
        String deliveryrequest = body.optString("deliveryrequest", "").trim();

        int usepoint = body.optInt("usepoint", 0);

        String imp_uid = body.optString("imp_uid", "");
        String merchant_uid = body.optString("merchant_uid", "");
        int paid_amount = body.optInt("paid_amount", 0);

        // ✅ 선택 cartnoList 받기
        JSONArray cartnoJsonArr = body.optJSONArray("cartnoList");
        if (cartnoJsonArr == null || cartnoJsonArr.length() == 0) {
            message = "주문할 상품이 없습니다.";
            loc = request.getContextPath() + "/order/cart.lp";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", 0);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        String[] cartnoArr = new String[cartnoJsonArr.length()];
        for (int i = 0; i < cartnoJsonArr.length(); i++) {
            cartnoArr[i] = String.valueOf(cartnoJsonArr.getInt(i));
        }

        // 기본 검증
        if (postcode.isEmpty() || address.isEmpty() || detailaddress.isEmpty()) {
            message = "배송지 정보가 누락되었습니다.";
            loc = "history.back()";
        }
        else if (usepoint < 0) {
            message = "포인트 값이 올바르지 않습니다.";
            loc = "history.back()";
        }
        else if (usepoint > loginuser.getPoint()) {
            message = "보유 포인트보다 많이 사용할 수 없습니다.";
            loc = "history.back()";
        }
        else if (paid_amount <= 0) {
            message = "결제 금액이 올바르지 않습니다.";
            loc = "history.back()";
        }
        else {

            CartDAO cdao = new CartDAO_imple();

            List<CartDTO> cartList = cdao.selectCartListByCartnoArr(userid, cartnoArr);

            if (cartList == null || cartList.isEmpty()) {
                message = "선택한 상품 정보를 찾을 수 없습니다.";
                loc = request.getContextPath() + "/order/cart.lp";
            }
            else {
                int sumTotalPoint = 0;
                for (CartDTO cdto : cartList) {
                    sumTotalPoint += cdto.getTotalPoint();
                }

                OrderDTO odto = new OrderDTO();
                odto.setUserid(userid);
                odto.setTotalprice(paid_amount);
                odto.setUsepoint(usepoint);
                odto.setTotalpoint(sumTotalPoint);

                odto.setPostcode(postcode);
                odto.setAddress(address);
                odto.setDetailaddress(detailaddress);
                odto.setExtraaddress(extraaddress);
                odto.setDeliveryrequest(deliveryrequest);

                try {
                    // 구매하기(저장, 업데이트)
                    int orderno = odao.insertOrderPay(odto, userid, cartList, cartnoArr);

                    if (orderno > 0) {
                        n = 1;

                        // 세션 포인트 갱신(UX용)
                        loginuser.setPoint(loginuser.getPoint() - usepoint + odto.getTotalpoint());

                        message = "주문이 완료되었습니다.";
                        loc = request.getContextPath() + "/my_info/my_order.lp";

						/*
						  System.out.println("[PAY] imp_uid=" + imp_uid + ", merchant_uid=" +
						  merchant_uid + ", paid_amount=" + paid_amount + ", usepoint=" + usepoint +
						  ", totalpoint=" + sumTotalPoint);
						 */
                    }
                    else {
                        message = "주문 저장에 실패했습니다.";
                        loc = "history.back()";
                    }
                }
                catch (Exception e) {
                    e.printStackTrace();
                    message = "주문 처리 중 오류가 발생했습니다.";
                    loc = "history.back()";
                }
            }
        }

        JSONObject jsonObj = new JSONObject();
        jsonObj.put("n", n);
        jsonObj.put("message", message);
        jsonObj.put("loc", loc);

        request.setAttribute("json", jsonObj.toString());
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/jsonview.jsp");
    }
}
