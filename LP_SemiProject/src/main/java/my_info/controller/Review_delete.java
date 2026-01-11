package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import member.model.*;

public class Review_delete extends AbstractController{


	@Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        String reviewno = request.getParameter("reviewno");
        
        MemberDAO mdao = new MemberDAO_imple();
        int n = mdao.deleteReview(reviewno);
        
        if(n == 1) {
            // 삭제 성공 시 메시지를 띄우고 부모창(마이페이지)을 새로고침합니다.
            request.setAttribute("message", "리뷰가 성공적으로 삭제되었습니다.");
            request.setAttribute("loc", request.getContextPath() + "/my_info/my_info.lp"); // 마이페이지 메인으로
        } else {
            request.setAttribute("message", "삭제에 실패하였습니다.");
            request.setAttribute("loc", "javascript:history.back()");
        }
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp"); // 메시지 전용 공통 JSP
    }
}
