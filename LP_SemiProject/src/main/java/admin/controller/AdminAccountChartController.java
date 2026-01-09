package admin.controller;

import java.util.*;
import org.json.JSONArray; // json 라이브러리 필요
import org.json.JSONObject;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import admin.model.AdminDAO;

public class AdminAccountChartController extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        // 1. 요청 파라미터 받기
        String searchType = request.getParameter("searchType"); // month or year
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
        
        // 2. DAO 호출
        AdminDAO adao = new AdminDAO();
        List<Map<String, String>> chartList = adao.getSalesChartData(paraMap);
        
        // 3. JSON 변환 (org.json 사용)
        JSONArray jsonArr = new JSONArray();
        
        for(Map<String, String> map : chartList) {
            JSONObject jsonObj = new JSONObject();
            jsonObj.put("label", map.get("label"));
            jsonObj.put("amount", map.get("amount"));
            jsonArr.put(jsonObj);
        }
        
        // 4. JSON 문자열 출력
        String json = jsonArr.toString();
        
        request.setAttribute("json", json);
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/jsonview.jsp"); // JSON 출력용 공통 JSP
    }
}