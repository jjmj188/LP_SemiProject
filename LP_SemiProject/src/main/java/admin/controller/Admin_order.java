package admin.controller;

import java.util.*;

import org.json.JSONObject; // JSON 처리를 위해 추가

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;

public class Admin_order extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        String mode = request.getParameter("mode"); // JS에서 보낸 mode 파라미터 확인
        
        InterAdminDAO adao = new AdminDAO();
        
        // [기능 2] 배송 시작 처리 (AJAX 요청)
        // POST 방식이고, mode가 "updateDelivery"일 때 실행
        if("POST".equalsIgnoreCase(method) && "updateDelivery".equals(mode)) {
            
            // 1. 파라미터 받기
            String orderno = request.getParameter("orderno");
            String invoice_no = request.getParameter("invoice_no");
            String delivery_company = request.getParameter("delivery_company");
            String receiverName = request.getParameter("receiverName");
            
            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("orderno", orderno);
            paraMap.put("invoice_no", invoice_no);
            paraMap.put("delivery_company", delivery_company);
            paraMap.put("receiverName", receiverName);
            
            // 2. DB 업데이트 실행
            int n = adao.updateDeliveryStart(paraMap); 
            
            // 3. 결과 JSON 반환
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("result", n); 
            
            String json = jsonObj.toString();
            request.setAttribute("json", json);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp"); // JSON 뷰로 이동
        }
        
        // [기능 1] 주문 전체 목록 조회 (화면 보여주기)
        // mode가 없거나 GET 방식일 때 실행
        else {
            Map<String, String> paraMap = new HashMap<>();
            
            // 주문 리스트 가져오기
            List<Map<String, String>> orderList = adao.getOrderList(paraMap);
            
            request.setAttribute("orderList", orderList);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/admin/admin_order.jsp");
        }
    }
}