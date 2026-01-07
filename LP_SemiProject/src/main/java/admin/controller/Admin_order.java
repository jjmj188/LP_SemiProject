package admin.controller;

import java.util.*;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;

public class Admin_order extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        // DAO 호출
        InterAdminDAO adao = new AdminDAO();
        Map<String, String> paraMap = new HashMap<>();
        
        // 주문 리스트 가져오기 (List<Map> 형태)
        List<Map<String, String>> orderList = adao.getOrderList(paraMap);
        
        request.setAttribute("orderList", orderList);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_order.jsp");
    }
}