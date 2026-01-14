package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class My_info extends AbstractController {

    private MemberDAO mdao = new MemberDAO_imple();

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        

    	//GET 직접 접근 차단
    			String referer = request.getHeader("referer");

    			if (referer == null) {

    			    request.setAttribute("message", "잘못된 접근입니다.");
    			    request.setAttribute("loc", request.getContextPath() + "/index.lp");

    			    super.setRedirect(false);
    			    super.setViewPage("/WEB-INF/msg.jsp");
    			    return;
    			}
    	

        String method = request.getMethod();
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
        
        
     // 1. 로그인 체크 및 휴면 여부 체크
        Boolean isLogin = (Boolean) session.getAttribute("isLogin");

        // [수정 포인트]
        if (isLogin == null || !isLogin) {
            String message = "";
            String loc = "";

            // 세션에 임시 아이디(idle_userid)가 있다는 건 휴면 상태라는 뜻
            String idle_userid = (String) session.getAttribute("idle_userid");

            if (idle_userid != null) {
                // 1) 휴면 상태인 사용자가 마이페이지를 누른 경우
                message = "휴면 상태입니다. 비밀번호 변경 후 이용 가능합니다.";
                loc = request.getContextPath() + "/login/idle_release.lp"; // 휴면해제 페이지로 가이드
            } else {
                // 2) 아예 로그인을 안 한 사용자인 경우
                message = "로그인 후 이용 가능합니다.";
                loc = request.getContextPath() + "/login/login.lp"; // 로그인 페이지로 이동
            }
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            
            super.setRedirect(false); 
            super.setViewPage("/WEB-INF/msg.jsp");
            return;
        }

        /* ============================================================
           GET 방식 : 페이지 보여주기 (새로고침 시 최신 포인트/정보 반영)
        ============================================================ */
        if ("GET".equalsIgnoreCase(method)) {
            // DB에서 최신 정보를 가져와서 세션을 갱신 (포인트 실시간 반영용)
            MemberDTO freshUser = mdao.getMemberByUserid(loginuser.getUserid());
            
            if (freshUser != null) {
                session.setAttribute("loginuser", freshUser);
            }
            
            setRedirect(false);
            setViewPage("/WEB-INF/my_info/my_info.jsp");
            return;
        }

        /* ============================================================
           POST 방식 : 회원 정보 수정 실행
        ============================================================ */
        if ("POST".equalsIgnoreCase(method)) {
            
            // 파라미터 가져오기
            String userid = loginuser.getUserid();
            String name = request.getParameter("name");
            String email = request.getParameter("email");
            String hp2 = request.getParameter("hp2");
            String hp3 = request.getParameter("hp3");
            String mobile = "010" + hp2 + hp3;
            
            String postcode = request.getParameter("postcode");
            String address = request.getParameter("address");
            String detailaddress = request.getParameter("detailaddress");
            String extraaddress = request.getParameter("extraaddress");

            // DTO에 담기
            MemberDTO member = new MemberDTO();
            member.setUserid(userid);
            member.setName(name);
            member.setEmail(email);
            member.setMobile(mobile);
            member.setPostcode(postcode);
            member.setAddress(address);
            member.setDetailaddress(detailaddress);
            member.setExtraaddress(extraaddress);
            
            // DB 업데이트 실행
            int n = mdao.updateMemberInfo(member);

            if (n == 1) {
                // 수정 성공 시: DB에서 최신 정보를 다시 가져와 세션에 저장 (포인트 유지를 위해)
                MemberDTO updatedUser = mdao.getMemberByUserid(userid);
                session.setAttribute("loginuser", updatedUser);

                request.setAttribute("message", "회원정보가 수정되었습니다.");
                request.setAttribute("loc", request.getContextPath() + "/my_info/my_info.lp");
            } else {
                request.setAttribute("message", "회원정보 수정에 실패했습니다.");
                request.setAttribute("loc", "javascript:history.back()");
            }

            setRedirect(false);
            setViewPage("/WEB-INF/msg.jsp");
            
        } else {
            // GET, POST 외의 접근 차단
            setRedirect(true);
            setViewPage(request.getContextPath() + "/index.lp");
        }
    }
}