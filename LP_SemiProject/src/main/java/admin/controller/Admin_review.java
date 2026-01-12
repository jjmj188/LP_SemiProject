package admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.json.JSONObject; // JSON 처리를 위해 필요

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;

public class Admin_review extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        String mode = request.getParameter("mode"); // 기능 구분 (목록:null, 삭제:delete)
        
        InterAdminDAO adao = new AdminDAO();
        
        // [기능 1] 리뷰 선택 삭제 (AJAX 요청)
        if("POST".equalsIgnoreCase(method) && "delete".equals(mode)) {
            deleteReview(request, response, adao);
        }
        // [기능 2] 리뷰 목록 조회 (기본 GET 방식)
        else {
            listReview(request, response, adao);
        }
    }
    
    // 리뷰 목록 조회 메소드
    private void listReview(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        Map<String, String> paraMap = new HashMap<>();
        
        // 1. 현재 페이지 번호 (기본값 1)
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 0;
        
        try {
            if(str_currentShowPageNo == null) currentShowPageNo = 1;
            else currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
        } catch(NumberFormatException e) {
            currentShowPageNo = 1;
        }
        
        int sizePerPage = 10; // 페이지당 10개
        
        // 2. 전체 리뷰 수 및 페이지 수 계산
        int totalCount = adao.getTotalReviewCount(paraMap);
        int totalPage = (int) Math.ceil((double)totalCount/sizePerPage);
        
        if(currentShowPageNo < 1) currentShowPageNo = 1;
        if(currentShowPageNo > totalPage) currentShowPageNo = totalPage;
        
        // 3. DB 조회 범위 계산
        int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
        int endRno = startRno + sizePerPage - 1;
        
        paraMap.put("startRno", String.valueOf(startRno));
        paraMap.put("endRno", String.valueOf(endRno));
        
        // 4. 리뷰 목록 조회 (DAO)
        List<Map<String, String>> reviewList = adao.getReviewListWithPaging(paraMap);
        
        // 5. 화면 표시용 시작 번호 (오름차순)
        int startIter = ((currentShowPageNo - 1) * sizePerPage) + 1;
        
        // 6. 페이지바 생성
        String pageBar = "";
        int blockSize = 10;
        int loop = 1;
        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        String url = "admin_review.lp";
        
        if(pageNo != 1) {
            pageBar += "<a href='"+url+"?currentShowPageNo="+(pageNo-1)+"' class='direction'>&lt;</a>";
        }
        while( !(loop > blockSize || pageNo > totalPage) ) {
            if(pageNo == currentShowPageNo) {
                pageBar += "<span class='active'>"+pageNo+"</span>";
            } else {
                pageBar += "<a href='"+url+"?currentShowPageNo="+pageNo+"'>"+pageNo+"</a>";
            }
            loop++;
            pageNo++;
        }
        if(pageNo <= totalPage) {
            pageBar += "<a href='"+url+"?currentShowPageNo="+pageNo+"' class='direction'>&gt;</a>";
        }
        
        request.setAttribute("reviewList", reviewList);
        request.setAttribute("pageBar", pageBar);
        request.setAttribute("totalCount", totalCount);
        request.setAttribute("startIter", startIter);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_review.jsp");
    }
    
    // 리뷰 삭제 메소드 (AJAX -> JSON 리턴)
    private void deleteReview(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        String reviewnos = request.getParameter("reviewnos"); // 예: "101,102,103"
        Map<String, Object> map = new HashMap<>();
        
        try {
            if(reviewnos != null && !reviewnos.trim().isEmpty()) {
                String[] reviewIdArr = reviewnos.split(",");
                
                // DAO의 다중 삭제 메소드 호출
                int n = adao.deleteMultiReviews(reviewIdArr); 
                
                if(n == reviewIdArr.length) { 
                    map.put("result", 1); // 성공
                } else {
                    map.put("result", 0); // 일부 실패
                    map.put("message", "일부 리뷰 삭제에 실패했습니다.");
                }
            } else {
                map.put("result", 0);
                map.put("message", "선택된 리뷰가 없습니다.");
            }
        } catch(Exception e) {
            e.printStackTrace();
            map.put("result", 0);
            map.put("message", "에러 발생: " + e.getMessage());
        }
        
        JSONObject jsonObj = new JSONObject(map);
        request.setAttribute("json", jsonObj.toString());
        
        super.setRedirect(false); 
        super.setViewPage("/WEB-INF/jsonview.jsp"); 
    }
}