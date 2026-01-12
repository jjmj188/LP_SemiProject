package my_info.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.WishListDAO;
import member.model.WishListDAO_imple;
import product.domain.ProductDTO;

public class My_wish extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // 1. 로그인 체크
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            super.setRedirect(true);
            super.setViewPage(request.getContextPath() + "/login/login.lp");
            return;
        }

        WishListDAO wdao = new WishListDAO_imple();
        String userid = loginuser.getUserid();

        // 2. 페이징 처리를 위한 변수 설정
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        
        int currentShowPageNo = 0; // 현재 보여주는 페이지 번호
        int sizePerPage = 8;       // 한 페이지당 보여줄 개수 (8개)
        int totalCount = 0;        // 총 찜 상품 개수
        int totalPage = 0;         // 총 페이지 수

        // 3. 총 찜 개수 구해오기
        totalCount = wdao.getTotalWishListCount(userid);

        // 4. 총 페이지 수 계산
        totalPage = (int) Math.ceil((double)totalCount / sizePerPage);

        // 5. 현재 페이지 번호 유효성
        if (str_currentShowPageNo == null) {
            currentShowPageNo = 1;
        } else {
            try {
                currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
                
                if(currentShowPageNo < 1 || (totalPage > 0 && currentShowPageNo > totalPage)) {
                    currentShowPageNo = 1;
                }
            } catch (NumberFormatException e) {
                currentShowPageNo = 1;
            }
        }
        
        if(totalPage == 0) {
        	currentShowPageNo = 1;
        }

        // 6. 현재 페이지에 해당하는 찜 목록(8개)만 조회해오기
        List<ProductDTO> wishList = wdao.selectWishListPaging(userid, sizePerPage, currentShowPageNo);

        request.setAttribute("wishList", wishList);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("currentShowPageNo", currentShowPageNo);
        request.setAttribute("totalCount", totalCount);
        
        // 7. 뷰 페이지 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/my_info/my_wish.jsp");
    }

}