package admin.controller;

import java.util.*;
import org.json.JSONObject;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import admin.model.AdminDAO;
import admin.model.InterAdminDAO;

public class Admin_order extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        String mode = request.getParameter("mode");
        
        InterAdminDAO adao = new AdminDAO();
        
        // [기능 2] 배송 시작 처리 (AJAX)
        if("POST".equalsIgnoreCase(method) && "updateDelivery".equals(mode)) {
            String orderno = request.getParameter("orderno");
            String invoice_no = request.getParameter("invoice_no");
            String delivery_company = request.getParameter("delivery_company");
            String receiverName = request.getParameter("receiverName");
            
            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("orderno", orderno);
            paraMap.put("invoice_no", invoice_no);
            paraMap.put("delivery_company", delivery_company);
            paraMap.put("receiverName", receiverName);
            
            int n = adao.updateDeliveryStart(paraMap); 
            
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("result", n); 
            
            String json = jsonObj.toString();
            request.setAttribute("json", json);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
        }
        
        // [추가 기능] 배송 완료 처리 (AJAX)
        else if("POST".equalsIgnoreCase(method) && "updateDeliveryEnd".equals(mode)) {
            String orderno = request.getParameter("orderno");
            
            // DAO에서 배송상태를 '배송완료'로 변경하는 메서드 호출
            int n = adao.updateDeliveryEnd(orderno); 
            
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("result", n); 
            
            String json = jsonObj.toString();
            request.setAttribute("json", json);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
        }
        
        // [기능 1] 주문 전체 목록 조회 + 필터링
        else {
            Map<String, String> paraMap = new HashMap<>();
            String status = request.getParameter("status");
            
            if(status != null && !status.trim().isEmpty()) {
                paraMap.put("status", status);
            }
            
            List<Map<String, String>> orderList = adao.getOrderList(paraMap);
            
            request.setAttribute("orderList", orderList);
            request.setAttribute("status", status); 
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/admin/admin_order.jsp");
        }
    }
}