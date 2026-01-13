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

    		// GET 직접 접근 차단
		String referer = request.getHeader("referer");
	
		if (referer == null) {
	
		    request.setAttribute("message", "잘못된 접근입니다.");
		    request.setAttribute("loc", request.getContextPath() + "/index.lp");
	
		    super.setRedirect(false);
		    super.setViewPage("/WEB-INF/msg.jsp");
		    return;
		}
    	
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            super.setRedirect(true);
            super.setViewPage(request.getContextPath() + "/login/login.lp");
            return;
        }

        WishListDAO wdao = new WishListDAO_imple();
        String userid = loginuser.getUserid();

        // 1. 페이징 변수 설정
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 1;
        int sizePerPage = 8;
        int blockSize = 10;

        if (str_currentShowPageNo != null) {
            try { currentShowPageNo = Integer.parseInt(str_currentShowPageNo); } catch (Exception e) {}
        }

        int totalCount = wdao.getTotalWishListCount(userid);
        int totalPage = (int) Math.ceil((double)totalCount / sizePerPage);

        if (currentShowPageNo > totalPage && totalPage != 0) {
            currentShowPageNo = totalPage;
        }

        // 2. 찜 목록 조회
        List<ProductDTO> wishList = wdao.selectWishListPaging(userid, sizePerPage, currentShowPageNo);

        // 3. [수정됨] 페이지바 생성 (goPage 함수 호출 방식)
        String pageBar = makePageBar(currentShowPageNo, totalPage, blockSize, request.getContextPath());
        request.setAttribute("pageBar", pageBar);

        request.setAttribute("wishList", wishList);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("currentShowPageNo", currentShowPageNo);
        request.setAttribute("totalCount", totalCount);

        super.setRedirect(false);
        super.setViewPage("/WEB-INF/my_info/my_wish.jsp");
    }

    // [수정된 메서드] 찜 목록 페이지바 생성 (Javascript goPage 함수 호출)
    private String makePageBar(int currentShowPageNo, int totalPage, int blockSize, String ctxPath) {
        if (totalPage == 0) return "";

        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        int loop = 1;

        StringBuilder sb = new StringBuilder();

        // [맨처음]
        if(currentShowPageNo == 1) {
            sb.append("<li class='page-item'><button class='page-btn first' disabled><span>맨처음</span></button></li>");
        } else {
            sb.append("<li class='page-item'><button class='page-btn first' onclick='goPage(1)'><span>맨처음</span></button></li>");
        }

        // [이전]
        if(currentShowPageNo == 1) {
            sb.append("<li class='page-item'><button class='page-btn prev' disabled><i class='fa-solid fa-chevron-left'></i></button></li>");
        } else {
            sb.append("<li class='page-item'><button class='page-btn prev' onclick='goPage(" + (currentShowPageNo - 1) + ")'><i class='fa-solid fa-chevron-left'></i></button></li>");
        }

        // [페이지 번호]
        while (!(loop > blockSize || pageNo > totalPage)) {
            if (pageNo == currentShowPageNo) {
                sb.append("<li class='page-item'><button class='page-num active'>" + pageNo + "</button></li>");
            } else {
                // 클릭 시 자바스크립트 goPage(페이지번호) 호출
                sb.append("<li class='page-item'><button class='page-num' onclick='goPage(" + pageNo + ")'>" + pageNo + "</button></li>");
            }
            loop++;
            pageNo++;
        }

        // [다음]
        if(currentShowPageNo == totalPage) {
            sb.append("<li class='page-item'><button class='page-btn next' disabled><i class='fa-solid fa-chevron-right'></i></button></li>");
        } else {
            sb.append("<li class='page-item'><button class='page-btn next' onclick='goPage(" + (currentShowPageNo + 1) + ")'><i class='fa-solid fa-chevron-right'></i></button></li>");
        }

        // [맨마지막]
        if(currentShowPageNo == totalPage) {
            sb.append("<li class='page-item'><button class='page-btn last' disabled><span>맨마지막</span></button></li>");
        } else {
            sb.append("<li class='page-item'><button class='page-btn last' onclick='goPage(" + totalPage + ")'><span>맨마지막</span></button></li>");
        }

        return sb.toString();
    }
}