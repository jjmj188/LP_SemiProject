package my_info.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.*;
import member.model.WishListDAO;
import member.model.WishListDAO_imple;
import product.domain.ProductDTO;

public class My_wish extends AbstractController {

	@Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // 로그인 체크
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            super.setRedirect(true);
            super.setViewPage(request.getContextPath() + "/login/login.lp");
            return;
        }

        // DAO를 통해 찜 목록 가져오기
        WishListDAO wdao = new WishListDAO_imple();
        List<ProductDTO> wishList = wdao.selectWishList(loginuser.getUserid());
        
        request.setAttribute("wishList", wishList);

        // my_wish.jsp 페이지로 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/my_info/my_wish.jsp");
    }

}
