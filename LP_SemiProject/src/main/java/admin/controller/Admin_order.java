package admin.controller;

import java.util.*;
import org.json.JSONObject;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; // 세션 관리를 위해 추가
import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.AdminVO; // 관리자 VO 객체 확인을 위해 필요

public class Admin_order extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
    // =============================================================
    // 관리자 로그인 여부 확인 (Security Check)
    // =============================================================
    HttpSession session = request.getSession();
    AdminVO loginAdmin = (AdminVO) session.getAttribute("loginAdmin"); 

    if (loginAdmin == null) {
        String message = "관리자만 접근 가능합니다.";
        String loc = request.getContextPath() + "/admin/admin_login.lp"; 
        
        request.setAttribute("message", message);
        request.setAttribute("loc", loc);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp");
        return; // 로그인이 안 되어 있으면 아래 로직을 수행하지 않고 종료
    }

        // =============================================================
        // 2. 기존 주문/배송 관리 로직 수행
        // =============================================================
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
            
            request.setAttribute("json", jsonObj.toString());
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
        }
        
        // [추가 기능] 배송 완료 처리 (AJAX)
        else if("POST".equalsIgnoreCase(method) && "updateDeliveryEnd".equals(mode)) {
            String orderno = request.getParameter("orderno");
            
            int n = adao.updateDeliveryEnd(orderno); 
            
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("result", n); 
            
            request.setAttribute("json", jsonObj.toString());
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
        }
        
        // [기능 1] 주문 전체 목록 조회 + 필터링 (기본 페이지 이동)
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