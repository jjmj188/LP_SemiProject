package admin.controller;

import java.io.PrintWriter;
import java.text.DecimalFormat;
import java.util.*;

import org.json.JSONArray;
import org.json.JSONObject;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import common.controller.AbstractController; 

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class Admin_account extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // =========================================================
        // 1. 관리자 로그인 여부 확인 (테스트를 위해 잠시 주석 처리 시작)
        // =========================================================
        /* HttpSession session = request.getSession();
        AdminVO loginadmin = (AdminVO) session.getAttribute("loginadmin");

        if (loginadmin == null) {
            String message = "관리자만 접근 가능합니다.";
            String loc = request.getContextPath() + "/admin/admin_login.lp"; 
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
            return;
        }
        */
        // =========================================================
        // (테스트를 위해 잠시 주석 처리 끝)
        // =========================================================

    	InterAdminDAO adao = new AdminDAO();         
        String mode = request.getParameter("mode");

        // =========================================================
        // 2. [AJAX] 차트 데이터 요청 처리 (JSON 응답)
        // =========================================================

        if("chartData".equals(mode)) {
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
            
            return; // 페이지 이동 없이 여기서 끝냄
        }

        // =========================================================
        // 3. [페이지 로딩] 요약 정보 조회
        // =========================================================
        
        // 1) 오늘 매출
        int todaySales = adao.getTodaySales(); 
        // 2) 이번 달 매출
        int monthSales = adao.getMonthSales();
        // 3) 누적 매출
        long totalSales = adao.getTotalSales();

        DecimalFormat df = new DecimalFormat("#,###");
        
        request.setAttribute("s_todaySales", df.format(todaySales));
        request.setAttribute("s_monthSales", df.format(monthSales));
        request.setAttribute("s_totalSales", df.format(totalSales));

        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_account.jsp");
    }
}