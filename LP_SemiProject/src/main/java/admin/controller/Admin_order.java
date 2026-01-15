package admin.controller;

import java.util.*;
import org.json.JSONObject;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession; 
import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.AdminVO; 

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
            return; 
        }

        // =============================================================
        // 2. 기존 주문/배송 관리 로직 수행
        // =============================================================
        String method = request.getMethod();
        String mode = request.getParameter("mode");
        
        InterAdminDAO adao = new AdminDAO();
        
        // [수정됨] JS의 "mode": "updateDeliveryStart" 와 일치시킴
        if("POST".equalsIgnoreCase(method) && "updateDeliveryStart".equals(mode)) {
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
        
        // [기능 3] 배송 완료 처리 (AJAX)
        else if("POST".equalsIgnoreCase(method) && "updateDeliveryEnd".equals(mode)) {
            String orderno = request.getParameter("orderno");
            
            int n = adao.updateDeliveryEnd(orderno); 
            
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("result", n); 
            
            request.setAttribute("json", jsonObj.toString());
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
        }
        
        // [기능 4] 배송지 주소 수정 (AJAX) - 이 부분을 추가하세요
        else if("POST".equalsIgnoreCase(method) && "updateOrderAddress".equals(mode)) {
            
            // 1. JS에서 보낸 파라미터 받기
            String orderno = request.getParameter("orderno");
            String postcode = request.getParameter("postcode");
            String address = request.getParameter("address");
            String detailaddress = request.getParameter("detailaddress");
            String extraaddress = request.getParameter("extraaddress");
            
            // 2. DAO로 넘길 Map 생성
            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("orderno", orderno);
            paraMap.put("postcode", postcode);
            paraMap.put("address", address);
            paraMap.put("detailaddress", detailaddress);
            paraMap.put("extraaddress", extraaddress);
            
            // 3. DAO 메소드 호출 (이미 구현되어 있음)
            int n = adao.updateOrderAddress(paraMap); 
            
            // 4. 결과 JSON 반환
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("result", n); 
            
            request.setAttribute("json", jsonObj.toString());
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
        }

        // [참고] JS에 있는 "주소 수정(updateOrderAddress)" 로직은 현재 Java 파일에 없습니다.
        // 만약 주소 수정 기능도 구현 중이시라면, 이곳에 else if 블록을 추가해야 합니다.
        
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