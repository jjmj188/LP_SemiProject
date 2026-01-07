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
        
        // 1. DAO 객체 생성
        InterAdminDAO adao = new AdminDAO();
        
        // 2. 검색 및 페이징 처리를 위한 맵 (현재는 비어있음 = 전체 조회)
        Map<String, String> paraMap = new HashMap<>();
        
        // 3. 상품 목록 가져오기
        List<ProductVO> productList = adao.getProductList(paraMap);
        
        // 4. 조회된 리스트를 request 영역에 저장 (JSP에서 사용)
        request.setAttribute("productList", productList);
        
        // 5. 뷰 페이지 설정 (forward 방식)
        // [참고] AbstractController 내부 로직에 따라 setRedirect, setViewPage가 동작함
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_product.jsp");
    }
}