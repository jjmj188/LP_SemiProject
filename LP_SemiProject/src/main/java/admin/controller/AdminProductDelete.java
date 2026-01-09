package admin.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import admin.model.AdminDAO;

public class AdminProductDelete extends AbstractController {
    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        if("POST".equalsIgnoreCase(request.getMethod())) {
            String[] pnums = request.getParameterValues("pseq"); // 체크박스 값 배열
            
            String message = "";
            String loc = "";
            
            if(pnums != null && pnums.length > 0) {
                AdminDAO adao = new AdminDAO();
                int n = adao.deleteProduct(pnums);
                
                if(n == 1) {
                    message = "선택한 상품이 삭제되었습니다.";
                    loc = request.getContextPath() + "/admin/admin_product.lp";
                } else {
                    message = "삭제 실패";
                    loc = "javascript:history.back()";
                }
            } else {
                message = "선택된 상품이 없습니다.";
                loc = "javascript:history.back()";
            }
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
        }
    }
}