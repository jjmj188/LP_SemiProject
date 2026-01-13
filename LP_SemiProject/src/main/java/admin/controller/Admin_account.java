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
        // 1. 관리자 로그인 여부 확인 (보안)
        // =============================================================
        HttpSession session = request.getSession();
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

        // =============================================================
        // 2. DAO 및 파라미터 준비
        // =============================================================
        InterAdminDAO adao = new AdminDAO();
        String mode = request.getParameter("mode"); // 차트 데이터 요청인지 일반 페이지 로딩인지 구분

        // =============================================================
        // [CASE A] 차트 데이터 요청 (AJAX 전용 - JSON 응답)
        // =============================================================
        if("chartData".equals(mode)) {
            
            String searchType = request.getParameter("searchType"); // month 또는 year
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
            
            // DAO에서 차트 데이터(날짜별 매출액) 조회
            List<Map<String, String>> chartList = adao.getSalesChartData(paraMap);
            
            JSONArray jsonArr = new JSONArray();
            
            if(chartList != null && !chartList.isEmpty()) {
                for(Map<String, String> map : chartList) {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("label", map.get("label"));    // X축 (날짜/연도)
                    jsonObj.put("amount", map.get("amount"));  // Y축 (매출액)
                    jsonArr.put(jsonObj);
                }
            }
            
            // ★ 중요: AJAX 요청이므로 JSON 문자열만 출력하고 종료
            response.setContentType("application/json; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(jsonArr.toString());
            out.flush();
            out.close();
            
            return; // 이후의 JSP 이동 로직(super.setViewPage)을 타지 않도록 종료
        }

        // =============================================================
        // [CASE B] 일반 페이지 로딩 처리 (매출 요약 정보 조회) -> JSP 이동
        // =============================================================
        
        // 1. 상단 요약 카드 데이터 조회 (오늘/이번달/전체 매출)
        int todaySales = adao.getTodaySales(); 
        int monthSales = adao.getMonthSales();
        long totalSales = adao.getTotalSales();
        
        // 2. 뷰(JSP)에서 <fmt:formatNumber>로 처리할 수 있도록 숫자 데이터 그대로 전달
        request.setAttribute("s_todaySales", todaySales);
        request.setAttribute("s_monthSales", monthSales);
        request.setAttribute("s_totalSales", totalSales);

        // 3. 페이지 이동 설정
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_account.jsp");
    }
}