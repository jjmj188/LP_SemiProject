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
        // 관리자 로그인 여부 확인
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
        // DAO 및 파라미터 준비
        // =============================================================
        InterAdminDAO adao = new AdminDAO();          
        String mode = request.getParameter("mode"); // 차트 데이터 요청인지 구분

        // =============================================================
        // [CASE A] AJAX 요청 처리 (차트 데이터 조회) -> JSON 응답
        // =============================================================
        if("chartData".equals(mode)) {
            
            // 검색 조건 받기
            String searchType = request.getParameter("searchType"); // "month" or "year"
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

            // 차트 데이터 가져오기
            List<Map<String, String>> chartList = adao.getSalesChartData(paraMap);

            // JSON 배열 생성
            JSONArray jsonArr = new JSONArray();
            if(chartList != null) {
                for(Map<String, String> map : chartList) {
                    JSONObject jsonObj = new JSONObject();
                    jsonObj.put("label", map.get("label"));    // X축 (날짜)
                    jsonObj.put("amount", map.get("amount"));  // Y축 (매출액)
                    jsonArr.put(jsonObj);
                }
            }
            
            // JSON 응답 전송
            String json = jsonArr.toString();
            response.setContentType("application/json; charset=UTF-8");
            PrintWriter out = response.getWriter();
            out.write(json);
            
            return; // JSP로 이동하지 않고 여기서 종료
        }

        // =============================================================
        // [CASE B] 페이지 로딩 처리 (매출 요약 정보 조회) -> JSP 이동
        // =============================================================
        
        // [수정 포인트] DecimalFormat 사용 안 함!
        // DB에서 숫자값 그대로 가져옵니다.
        int todaySales = adao.getTodaySales(); 
        int monthSales = adao.getMonthSales();
        long totalSales = adao.getTotalSales();
        
        // [수정 포인트] 숫자를 문자열로 변환하지 않고 그대로 setAttribute 합니다.
        // JSP의 <fmt:formatNumber> 태그가 이 숫자를 받아서 쉼표(,)를 찍어줍니다.
        request.setAttribute("s_todaySales", todaySales);
        request.setAttribute("s_monthSales", monthSales);
        request.setAttribute("s_totalSales", totalSales);

        // 뷰 페이지(JSP)로 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_account.jsp");
    }
}