package admin.controller;

import java.util.*;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;

public class Admin_review extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        // DAO 호출
        InterAdminDAO adao = new AdminDAO();
        Map<String, String> paraMap = new HashMap<>();
        
        // 리뷰 목록 가져오기
        List<Map<String, String>> reviewList = adao.getReviewList(paraMap);
        
        request.setAttribute("reviewList", reviewList);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_review.jsp");
    }
}