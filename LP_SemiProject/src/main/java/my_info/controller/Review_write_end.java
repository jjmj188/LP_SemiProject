package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import product.model.ReviewDAO;
import product.model.ReviewDAO_imple;

public class Review_write_end extends AbstractController {

    private ReviewDAO rdao = new ReviewDAO_imple();

    private void writeJson(HttpServletResponse response, boolean ok, String msg) throws Exception {
        response.reset();
        response.setCharacterEncoding("UTF-8");
        response.setContentType("application/json; charset=UTF-8");

        // msg에 따옴표가 들어가면 JSON 깨질 수 있으니 최소한의 escape
        String safeMsg = (msg == null) ? "" : msg.replace("\\", "\\\\").replace("\"", "\\\"");
        response.getWriter().write("{\"ok\":" + ok + ",\"msg\":\"" + safeMsg + "\"}");
    }

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        // POST만
        if (!"POST".equalsIgnoreCase(request.getMethod())) {
            writeJson(response, false, "잘못된 요청입니다.");
            return;
        }

        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            writeJson(response, false, "로그인 후 이용 가능합니다.");
            return;
        }

        String strOrderno = request.getParameter("orderno");
        String strProductno = request.getParameter("productno");
        String strRating = request.getParameter("rating");
        String content = request.getParameter("reviewcontent");

        int orderno, productno, rating;

        try {
            orderno = Integer.parseInt(strOrderno);
            productno = Integer.parseInt(strProductno);
            rating = Integer.parseInt(strRating);
        } catch (Exception e) {
            writeJson(response, false, "입력값이 올바르지 않습니다.");
            return;
        }

        // ✅ 별점 1~5 강제
        if (rating < 1 || rating > 5) {
            writeJson(response, false, "별점은 1~5점만 가능합니다.");
            return;
        }

        if (content == null) content = "";
        content = content.trim();

        // ✅ 100자 이내 강제 (프론트 조작 대비)
        if (content.length() > 100) {
            writeJson(response, false, "리뷰 내용은 100자 이내로 작성해주세요.");
            return;
        }

        String userid = loginuser.getUserid();

        // ✅ 구매 검증 (내 주문의 상품인지)
        if (rdao.selectOrderItemForReview(userid, orderno, productno) == null) {
            writeJson(response, false, "구매한 상품만 리뷰를 작성할 수 있습니다.");
            return;
        }

        // ✅ 중복 검증
        if (rdao.existsReview(userid, productno, orderno)) {
            writeJson(response, false, "이미 작성한 리뷰입니다.");
            return;
        }

        // ✅ INSERT
        int n = rdao.insertReview(userid, productno, orderno, rating, content);

        if (n == 1) {
            writeJson(response, true, "리뷰가 등록되었습니다.");
        } else {
            writeJson(response, false, "리뷰 등록에 실패했습니다.");
        }
    }
}
