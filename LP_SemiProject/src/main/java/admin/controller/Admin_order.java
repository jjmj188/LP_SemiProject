// src/main/java/admin/controller/Admin_order.java

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
        
        // [기능 2] 배송 시작 처리 (AJAX) - 기존 유지
        if("POST".equalsIgnoreCase(method) && "updateDelivery".equals(mode)) {
            // ... (기존 코드 유지) ...
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
        
        // [기능 1] 주문 전체 목록 조회 + 필터링 기능 추가
        else {
            Map<String, String> paraMap = new HashMap<>();
            
            // 1. 클릭한 버튼의 상태값(status)을 받아옵니다. (예: "배송준비중", "배송중")
            String status = request.getParameter("status");
            
            // 2. 파라미터가 있다면 map에 담습니다.
            if(status != null && !status.trim().isEmpty()) {
                paraMap.put("status", status);
            }
            
            // 3. DAO 호출
            List<Map<String, String>> orderList = adao.getOrderList(paraMap);
            
            request.setAttribute("orderList", orderList);
            request.setAttribute("status", status); // 현재 선택된 필터 상태를 JSP로 전달 (버튼 활성화용)
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/admin/admin_order.jsp");
        }
    }
}