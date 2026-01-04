package member.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class MemberWithdraw extends AbstractController {
	private MemberDAO mdao = new MemberDAO_imple();
	   
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		String method = request.getMethod();
	    HttpSession session = request.getSession();
	    MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

	    // [1] 로그인 체크는 모든 로직의 최상단에 있는 것이 좋습니다.
	    if (loginuser == null) {
	        setRedirect(true);
	        setViewPage(request.getContextPath() + "/login/login.lp");
	        return;
	    }

	    // [2] GET : 탈퇴 입력 화면 보여주기
	    if ("GET".equalsIgnoreCase(method)) {
	        setRedirect(false);
	        setViewPage("/WEB-INF/member/member_withdraw.jsp");
	        return;
	    }

	    // [3] POST : 실제 탈퇴 처리 (비밀번호 확인 후 업데이트)
	    String userid = loginuser.getUserid();
	    String pwd = request.getParameter("pwd");

	    // DAO에서 비밀번호 일치 여부 확인 (status=1 조건 포함)
	    boolean isCorrect = mdao.checkPassword(userid, pwd);

	    if (!isCorrect) {
	        request.setAttribute("message", "비밀번호가 일치하지 않습니다.");
	        request.setAttribute("loc", "javascript:history.back()");
	        
	        setRedirect(false);
	        setViewPage("/WEB-INF/msg.jsp");
	        return;
	    }

	    // [4] 실제 DB 상태 업데이트 (status=0, idle_date=sysdate)
	    int n = mdao.withdrawMember(userid);

	    if (n == 1) {
	        // 탈퇴 성공 시 세션 제거
	        session.invalidate();

	        //  바로 가입 페이지로 보내기보다 완료 메시지
	        request.setAttribute("message", "회원탈퇴가 성공적으로 완료되었습니다. 그동안 이용해주셔서 감사합니다.");
	        request.setAttribute("loc", request.getContextPath() + "/index.lp"); // 메인으로 이동
	        
	        setRedirect(false);
	        setViewPage("/WEB-INF/msg.jsp");
	    } else {
	        // 혹시 모를 DB 오류 대비
	        request.setAttribute("message", "탈퇴 처리 중 오류가 발생했습니다. 관리자에게 문의하세요.");
	        request.setAttribute("loc", "javascript:history.back()");
	        
	        setRedirect(false);
	        setViewPage("/WEB-INF/msg.jsp");
	    }
	}
	

}//end
