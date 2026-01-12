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

        // 1. 관리자 로그인 체크
        HttpSession session = request.getSession();
        // [중요] 세션 키 대소문자 확인 (loginAdmin)
        AdminVO loginadmin = (AdminVO) session.getAttribute("loginAdmin"); 

        if (loginadmin == null) {
            String message = "관리자만 접근 가능합니다.";
            String loc = request.getContextPath() + "/admin/admin_login.lp"; 
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        // 2. DAO 및 파라미터 준비
        InterAdminDAO adao = new AdminDAO();         
        String mode = request.getParameter("mode");

        // [CASE A] AJAX 요청 처리 (차트) - 기존과 동일
        if("chartData".equals(mode)) {
            // ... (기존 코드 유지) ...
            String searchType = request.getParameter("searchType");
            String startDate  = request.getParameter("startDate");
            String endDate    = request.getParameter("endDate");
            String startYear  = request.getParameter("startYear");
            String endYear    = request.getParameter("endYear");

            Map<String, String> paraMap = new HashMap<>();
            paraMap.put("searchType", searchType);
            paraMap.put("startDate", startDate);
            paraMap.put("endDate", endDate);
            paraMap.put("startYear", startYear);
            paraMap.put("endYear", endYear);

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
            
            String json = jsonArr.toString();
            response.setContentType("application/json; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(json);
            
            return; 
        }

        // =========================================================
        // [CASE B] 페이지 로딩 처리 - 매출 요약 정보 (JSP 이동)
        // =========================================================
        // ★ 수정된 부분: DecimalFormat을 사용하지 않고 숫자 그대로 넘깁니다. ★
        
        int todaySales = adao.getTodaySales(); 
        int monthSales = adao.getMonthSales();
        long totalSales = adao.getTotalSales();
        
        // 포맷팅(문자열 변환) 없이 숫자형(int, long) 그대로 저장
        request.setAttribute("s_todaySales", todaySales);
        request.setAttribute("s_monthSales", monthSales);
        request.setAttribute("s_totalSales", totalSales);

        // 뷰 페이지 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_account.jsp");
    }
}