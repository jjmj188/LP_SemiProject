package product.controller;

import org.json.JSONObject;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.WishListDAO;
import member.model.WishListDAO_imple;

public class WishToggle extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String method = request.getMethod();
        JSONObject jsonObj = new JSONObject();

        // 1. POST 방식만 허용
        if (!"POST".equalsIgnoreCase(method)) {
            jsonObj.put("isSuccess", false);
            jsonObj.put("message", "잘못된 접근입니다.");
        } 
        else {
            // 2. 로그인 체크
            HttpSession session = request.getSession();
            MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
    
            if (loginuser == null) {
                jsonObj.put("isSuccess", false);
                jsonObj.put("requireLogin", true);
            } 
            else {
                String userid = loginuser.getUserid();
                String productnoStr = request.getParameter("productno");
                
                try {
                    int productno = Integer.parseInt(productnoStr);
                    
                    WishListDAO wdao = new WishListDAO_imple();
                    // 토글 실행 (1:추가됨, 0:삭제됨)
                    int result = wdao.toggleWishList(userid, productno);
                    
                    jsonObj.put("isSuccess", true);
                    jsonObj.put("result", result); 
                } catch (Exception e) {
                    jsonObj.put("isSuccess", false);
                    jsonObj.put("message", "처리 중 오류가 발생했습니다.");
                    e.printStackTrace();
                }
            }
        }
        
        request.setAttribute("json", jsonObj.toString());
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/jsonview.jsp");
    }
}