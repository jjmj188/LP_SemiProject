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
        
        String method = request.getMethod();
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        // 1. 로그인 체크
        if (loginuser == null) {
            setRedirect(true);
            setViewPage(request.getContextPath() + "/login/login.lp");
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