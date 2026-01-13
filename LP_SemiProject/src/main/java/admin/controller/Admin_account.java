package admin.controller;

import java.io.PrintWriter;
import java.util.*;

import org.json.JSONArray;
import org.json.JSONObject;

import admin.model.AdminDAO;
import admin.model.AdminVO;
import admin.model.InterAdminDAO;
import common.controller.AbstractController; 

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

public class Admin_account extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // =============================================================
        // 1. 관리자 로그인 여부 확인
        // =============================================================
        HttpSession session = request.getSession();
        AdminVO loginadmin = (AdminVO) session.getAttribute("loginAdmin"); 

        if (loginadmin == null) {
            request.setAttribute("message", "관리자만 접근 가능합니다.");
            request.setAttribute("loc", request.getContextPath() + "/admin/admin_login.lp");
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        InterAdminDAO adao = new AdminDAO();
        String mode = request.getParameter("mode"); 

        // =============================================================
        // [CASE A] 차트 데이터 요청 (AJAX 전용)
        // =============================================================
        if("chartData".equals(mode)) {
            
            String searchType = request.getParameter("searchType");
            String startDate = request.getParameter("startDate");
            String endDate = request.getParameter("endDate");
            String startYear = request.getParameter("startYear");
            String endYear = request.getParameter("endYear");
            
            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("searchType", searchType);
            paraMap.put("startDate", startDate);
            paraMap.put("endDate", endDate);
            paraMap.put("startYear", startYear);
            paraMap.put("endYear", endYear);
            
            // DAO에서 차트 데이터 조회
            List<Map<String, String>> chartList = adao.getSalesChartData(paraMap);
            
            JSONArray jsonArr = new JSONArray();
            if(chartList != null) {
                for(Map<String, String> map : chartList) {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("label", map.get("label"));    
                    jsonObj.put("amount", map.get("amount"));  
                    jsonArr.put(jsonObj);
                }
            }
            
            // 응답 헤더 설정 (JSON)
            response.setContentType("application/json; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(jsonArr.toString());
            out.flush();
            out.close();
            
            // ★ 중요: FrontController가 forward를 시도하지 않도록 viewPage를 null로 설정
            super.setViewPage(null); 
            return; 
        }

        // =============================================================
        // [CASE B] 일반 페이지 로딩 처리 (매출 요약 정보 조회)
        // =============================================================
        
        // 상단 요약 카드 데이터 조회
        int todaySales = adao.getTodaySales(); 
        int monthSales = adao.getMonthSales();
        long totalSales = adao.getTotalSales();
        
        request.setAttribute("s_todaySales", todaySales);
        request.setAttribute("s_monthSales", monthSales);
        request.setAttribute("s_totalSales", totalSales);

        // JSP 페이지 이동 설정
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_account.jsp");
    }
}