package admin.controller;

import java.util.*;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.InquiryVO; 

public class Admin_inquiry extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // 1. DAO 호출
        InterAdminDAO adao = new AdminDAO();
        Map<String, String> paraMap = new HashMap<>();

        // (선택사항) 페이징 처리를 하려면 currentShowPageNo 등을 paraMap에 넣어야 함
        // paraMap.put("currentShowPageNo", request.getParameter("currentShowPageNo"));

        // 2. 문의 내역 리스트 가져오기
        List<InquiryVO> inquiryList = adao.getInquiryList(paraMap);

        // 3. JSP로 데이터 넘기기
        request.setAttribute("inquiryList", inquiryList);

        // 4. 페이지 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_inquiry.jsp");
    }
}