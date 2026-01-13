package admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import admin.model.AdminDAO;
import admin.model.AdminVO;
import admin.model.InterAdminDAO;
import admin.model.MemberVO;

public class Admin_member extends AbstractController {

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
    
        String method = request.getMethod();
        String mode = request.getParameter("mode");
        
        InterAdminDAO adao = new AdminDAO();
        
        if("POST".equalsIgnoreCase(method) && "delete".equals(mode)) {
            deleteMember(request, response, adao);
        }
        else {
            listMember(request, response, adao);
        }
    }
    
    // [기능 1] 회원 목록 조회
    private void listMember(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        String searchType = request.getParameter("searchType");
        String searchWord = request.getParameter("searchWord");
        
        if(searchWord == null || searchWord.trim().isEmpty()) {
            searchWord = "";
            searchType = "name"; 
        }
        
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 0;
        
        try {
            if(str_currentShowPageNo == null) currentShowPageNo = 1;
            else currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
        } catch(NumberFormatException e) {
            currentShowPageNo = 1;
        }
        
        int sizePerPage = 10; 
        
        Map<String, String> paraMap = new HashMap<>();
        paraMap.put("searchType", searchType);
        paraMap.put("searchWord", searchWord);
        
        int totalCount = adao.getTotalMemberCount(paraMap); 
        int totalPage = (int) Math.ceil((double)totalCount/sizePerPage);
        
        if(currentShowPageNo < 1) currentShowPageNo = 1;
        if(currentShowPageNo > totalPage) currentShowPageNo = totalPage;
        
        int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
        int endRno = startRno + sizePerPage - 1;
        
        paraMap.put("startRno", String.valueOf(startRno));
        paraMap.put("endRno", String.valueOf(endRno));
        
        List<MemberVO> memberList = adao.getMemberListWithPaging(paraMap);
        
        // ==================================================================
        // [수정 포인트] 오름차순 번호의 시작값 계산 (1, 11, 21...)
        // 공식: ((현재페이지 - 1) * 페이지당보여줄개수) + 1
        // 예: 1페이지 -> 0*10 + 1 = 1
        // 예: 2페이지 -> 1*10 + 1 = 11
        // ==================================================================
        int startIter = ((currentShowPageNo - 1) * sizePerPage) + 1;
        
        String pageBar = "";
        int blockSize = 10;
        int loop = 1;
        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        
        String url = "admin_member.lp";
        String searchParam = "&searchType=" + searchType + "&searchWord=" + searchWord;
        
        if(pageNo != 1) {
            pageBar += "<a href='"+url+"?currentShowPageNo="+(pageNo-1)+searchParam+"' class='direction'>&lt;</a>";
        }
        
        while( !(loop > blockSize || pageNo > totalPage) ) {
            if(pageNo == currentShowPageNo) {
                pageBar += "<span class='active'>"+pageNo+"</span>";
            } else {
                pageBar += "<a href='"+url+"?currentShowPageNo="+pageNo+searchParam+"'>"+pageNo+"</a>";
            }
            loop++;
            pageNo++;
        }
        
        if(pageNo <= totalPage) {
            pageBar += "<a href='"+url+"?currentShowPageNo="+pageNo+searchParam+"' class='direction'>&gt;</a>";
        }
        
        request.setAttribute("memberList", memberList);
        request.setAttribute("searchType", searchType);
        request.setAttribute("searchWord", searchWord);
        request.setAttribute("pageBar", pageBar);
        request.setAttribute("totalCount", totalCount);
        
        request.setAttribute("startIter", startIter); // 계산된 시작값 넘김
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_member.jsp");
    }
    
    private void deleteMember(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        String[] userids = request.getParameterValues("userid");
        String message = "";
        String loc = "";
        
        if(userids != null && userids.length > 0) {
            int n = adao.deleteMember(userids);
            
            if(n > 0) {
                message = "선택한 회원이 탈퇴 처리되었습니다.";
                loc = request.getContextPath() + "/admin/admin_member.lp"; 
            } else {
                message = "탈퇴 처리에 실패했습니다.";
                loc = "javascript:history.back()";
            }
        } else {
            message = "선택된 회원이 없습니다.";
            loc = "javascript:history.back()";
        }
        
        request.setAttribute("message", message);
        request.setAttribute("loc", loc);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp");
    }
}