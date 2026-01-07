package admin.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.MemberVO;

public class Admin_member extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        // 1. 검색어 파라미터 받기 (JSP의 검색창 <input name="searchWord">)
        String searchWord = request.getParameter("searchWord");
        
        // 검색어가 없이 들어왔을 경우 (메뉴 눌러서 처음 들어왔을 때)
        if(searchWord == null) {
            searchWord = "";
        }
        
        // 2. DAO에 넘겨줄 파라미터 맵 만들기
        Map<String, String> paraMap = new HashMap<>();
        paraMap.put("searchWord", searchWord);
        
        // 3. DAO 호출하여 회원 목록 가져오기
        InterAdminDAO adao = new AdminDAO();
        List<MemberVO> memberList = adao.getMemberList(paraMap);
        
        // 4. JSP에서 사용할 수 있도록 request 영역에 저장
        request.setAttribute("memberList", memberList); // 회원 리스트
        request.setAttribute("searchWord", searchWord); // 검색어 유지용
        
        // 5. 페이지 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_member.jsp");
        
    }

}