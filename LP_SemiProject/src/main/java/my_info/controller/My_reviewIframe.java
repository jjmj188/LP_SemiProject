package my_info.controller;

import java.util.List;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;
import product.domain.ReviewDTO;

public class My_reviewIframe extends AbstractController {


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
	    
	    
	    
	    if(loginuser != null) {
	        String userid = loginuser.getUserid();
	        MemberDAO mdao = new MemberDAO_imple();
	        
	        // 1. 부모창 모달에서 보낸 reviewno가 있는지 확인
	        String reviewno = request.getParameter("reviewno");

	        if (reviewno == null) {
	            // [상황 1] 리뷰 번호가 없을 때 -> 전체 리스트 조회 (처음 마이페이지 열 때)
	            List<ReviewDTO> reviewList = mdao.selectMyReviewList(userid);
	            request.setAttribute("reviewList", reviewList);

	            super.setRedirect(false);
	            super.setViewPage("/WEB-INF/my_info/my_review_iframe.jsp"); 
	        } 
	        else {
	            // [상황 2] 리뷰 번호가 있을 때 -> 특정 리뷰 상세 조회 (모달 열릴 때)
	            // (주의: selectOneReview 메서드가 DAO에 구현되어 있어야 합니다)
	            ReviewDTO rdto = mdao.selectOneReview(Integer.parseInt(reviewno));
	            request.setAttribute("rdto", rdto);
	            
	            super.setRedirect(false);
	            super.setViewPage("/WEB-INF/my_info/my_review_delete.jsp"); 
	        }
	    } else {
	        // 로그인이 안 된 경우 처리 (필요시)
	        super.setRedirect(true);
	        super.setViewPage(request.getContextPath() + "/login/login.lp");
	    }
	
	}

}