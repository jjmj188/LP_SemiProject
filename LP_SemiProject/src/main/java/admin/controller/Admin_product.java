package admin.controller;

import java.util.*;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.ProductVO;

public class Admin_product extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        // DAO 호출
        InterAdminDAO adao = new AdminDAO();
        Map<String, String> paraMap = new HashMap<>();
        
        // 상품 리스트 가져오기
        List<ProductVO> productList = adao.getProductList(paraMap);
        
        // JSP로 넘기기
        request.setAttribute("productList", productList);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_product.jsp");
    }
}