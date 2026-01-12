package admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.InquiryVO;

public class Admin_inquiry extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String method = request.getMethod();
        
        InterAdminDAO adao = new AdminDAO();
        
        // 1. 답변 등록 (POST 방식) - 기존 AdminInquiryReplyEnd 기능 통합
        if("POST".equalsIgnoreCase(method)) {
            replyInquiry(request, response, adao);
        }
        // 2. 문의 목록 조회 (GET 방식)
        else {
            listInquiry(request, response, adao);
        }
    }
    
    // [기능 1] 문의 목록 조회 (페이징 + 오름차순)
    private void listInquiry(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        Map<String, String> paraMap = new HashMap<>();
        
        // 1. 페이지 번호 설정
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 0;
        
        try {
            if(str_currentShowPageNo == null) currentShowPageNo = 1;
            else currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
        } catch(NumberFormatException e) {
            currentShowPageNo = 1;
        }
        
        int sizePerPage = 10; // 페이지당 10개
        
        // 2. 전체 개수 및 페이지 수 계산
        int totalCount = adao.getTotalInquiryCount(paraMap);
        int totalPage = (int) Math.ceil((double)totalCount/sizePerPage);
        
        if(currentShowPageNo < 1) currentShowPageNo = 1;
        if(currentShowPageNo > totalPage) currentShowPageNo = totalPage;
        
        // 3. DB 조회 범위
        int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
        int endRno = startRno + sizePerPage - 1;
        
        paraMap.put("startRno", String.valueOf(startRno));
        paraMap.put("endRno", String.valueOf(endRno));
        
        // 4. 목록 조회 (DAO 호출)
        List<InquiryVO> inquiryList = adao.getInquiryListWithPaging(paraMap);
        
        // 5. 화면 표시용 시작 번호 (오름차순: 1, 11, 21...)
        int startIter = ((currentShowPageNo - 1) * sizePerPage) + 1;
        
        // 6. 페이지바 생성
        String pageBar = "";
        int blockSize = 10;
        int loop = 1;
        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        String url = "admin_inquiry.lp";
        
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
        
        request.setAttribute("inquiryList", inquiryList);
        request.setAttribute("pageBar", pageBar);
        request.setAttribute("startIter", startIter);
        request.setAttribute("totalCount", totalCount);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_inquiry.jsp");
    }
    
    // [기능 2] 답변 등록
    private void replyInquiry(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        String inquiryno = request.getParameter("inquiryno");
        String adminreply = request.getParameter("adminreply");
        
        int n = adao.replyInquiry(inquiryno, adminreply);
        
        String message = "";
        String loc = "";
        
        if(n == 1) {
            message = "답변이 등록되었습니다.";
            loc = request.getContextPath() + "/admin/admin_inquiry.lp"; 
        } else {
            message = "답변 등록 실패";
            loc = "javascript:history.back()";
        }
        
        request.setAttribute("message", message);
        request.setAttribute("loc", loc);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp");
    }
}