package my_info.controller;

import java.sql.SQLException;
import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.domain.InquiryDTO;
import member.model.InquiryDAO;
import member.model.InquiryDAO_imple;

public class My_inquiry extends AbstractController {

  private InquiryDAO Iqdao = new InquiryDAO_imple();

  @Override
  public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

    HttpSession session = request.getSession();
    MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

    if (loginuser == null) {
      super.setRedirect(true);
      super.setViewPage(request.getContextPath() + "/login/login.lp");
      return;
    }

    String method = request.getMethod();
    String userid = loginuser.getUserid();

    if ("GET".equalsIgnoreCase(method)) {

      // ===== 페이징 정책: 회원목록과 동일 =====
      final int sizePerPage = 6;
      final int blockSize   = 6;

      String currentShowPageNo = request.getParameter("currentShowPageNo");
      if (currentShowPageNo == null) currentShowPageNo = "1";

      try {
        // 총 문의 수 / 총 페이지
        int totalInquiryCount = Iqdao.getTotalInquiryCount(userid);
        int totalPage = (int) Math.ceil((double) totalInquiryCount / sizePerPage);

        // currentShowPageNo 방어
        try {
          int page = Integer.parseInt(currentShowPageNo);
          if (page <= 0 || (totalPage > 0 && page > totalPage)) {
            currentShowPageNo = "1";
          }
        } catch (NumberFormatException e) {
          currentShowPageNo = "1";
        }

        // 목록 조회 (페이징)
        List<InquiryDTO> inquiryList = Iqdao.selectInquiryPaging(userid,
            Integer.parseInt(currentShowPageNo), sizePerPage);

        // pageBar 만들기
        String pageBar = makePageBar(currentShowPageNo, totalPage, blockSize, request.getContextPath());

        request.setAttribute("inquiryList", inquiryList);
        request.setAttribute("pageBar", pageBar);

        request.setAttribute("sizePerPage", sizePerPage);
        request.setAttribute("totalInquiryCount", totalInquiryCount);
        request.setAttribute("currentShowPageNo", currentShowPageNo);

      } catch (SQLException e) {
        e.printStackTrace();
        request.setAttribute("inquiryList", null);
        request.setAttribute("pageBar", "");
        request.setAttribute("errMsg", "문의내역 조회 중 오류가 발생했습니다.");
      }

      super.setRedirect(false);
      super.setViewPage("/WEB-INF/my_info/my_inquiry.jsp");
      return;
    }

    // POST: 문의 등록
    String inquirycontent = request.getParameter("inquirycontent");

    String message = "";
    String loc = "";

    if (inquirycontent == null || inquirycontent.trim().isEmpty()) {
      message = "문의 내용을 입력하세요.";
      loc = "javascript:history.back()";
      request.setAttribute("message", message);
      request.setAttribute("loc", loc);
      super.setRedirect(false);
      super.setViewPage("/WEB-INF/msg.jsp");
      return;
    }

    try {
      int n = Iqdao.insertInquiry(userid, inquirycontent.trim());

      if (n == 1) {
        message = "문의가 정상적으로 접수되었습니다.";
        loc = request.getContextPath() + "/my_info/my_inquiry.lp";
      } else {
        message = "문의 등록에 실패했습니다.";
        loc = "javascript:history.back()";
      }

    } catch (SQLException e) {
      e.printStackTrace();
      message = "서버 오류로 문의 등록에 실패했습니다.";
      loc = "javascript:history.back()";
    }

    request.setAttribute("message", message);
    request.setAttribute("loc", loc);

    super.setRedirect(false);
    super.setViewPage("/WEB-INF/msg.jsp");
  }


  private String makePageBar(String currentShowPageNo, int totalPage, int blockSize, String ctxPath) {

	  if (totalPage == 0) return "";

	  int current = Integer.parseInt(currentShowPageNo);

	  // 블록 시작 페이지
	  int pageNo = ((current - 1) / blockSize) * blockSize + 1;
	  int loop = 1;

	  String baseUrl = ctxPath + "/my_info/my_inquiry.lp?currentShowPageNo=";

	  StringBuilder sb = new StringBuilder();

	  // ===== [맨처음] =====
	  if (current == 1) {
	    sb.append("<button class='page-btn first' disabled>")
	      .append("<span>맨처음</span>")
	      .append("</button>");
	  } else {
	    sb.append("<button class='page-btn first' ")
	      .append("onclick=\"location.href='").append(baseUrl).append("1'\">")
	      .append("<span>맨처음</span>")
	      .append("</button>");
	  }

	  // ===== [이전] (현재페이지 기준) =====
	  if (current == 1) {
	    sb.append("<button class='page-btn prev' disabled>")
	      .append("<i class='fa-solid fa-chevron-left'></i>")
	      .append("</button>");
	  } else {
	    sb.append("<button class='page-btn prev' ")
	      .append("onclick=\"location.href='").append(baseUrl).append(current - 1).append("'\">")
	      .append("<i class='fa-solid fa-chevron-left'></i>")
	      .append("</button>");
	  }

	  // ===== 숫자(블록 단위로 6개) =====
	  while (!(loop > blockSize || pageNo > totalPage)) {

	    if (pageNo == current) {
	      sb.append("<button class='page-num active'>")
	        .append(pageNo)
	        .append("</button>");
	    } else {
	      sb.append("<button class='page-num' ")
	        .append("onclick=\"location.href='").append(baseUrl).append(pageNo).append("'\">")
	        .append(pageNo)
	        .append("</button>");
	    }

	    loop++;
	    pageNo++;
	  }

	  // ===== [다음] (현재페이지 기준) =====
	  if (current == totalPage) {
	    sb.append("<button class='page-btn next' disabled>")
	      .append("<i class='fa-solid fa-chevron-right'></i>")
	      .append("</button>");
	  } else {
	    sb.append("<button class='page-btn next' ")
	      .append("onclick=\"location.href='").append(baseUrl).append(current + 1).append("'\">")
	      .append("<i class='fa-solid fa-chevron-right'></i>")
	      .append("</button>");
	  }

	  // ===== [맨마지막] =====
	  if (current == totalPage) {
	    sb.append("<button class='page-btn last' disabled>")
	      .append("<span>맨마지막</span>")
	      .append("</button>");
	  } else {
	    sb.append("<button class='page-btn last' ")
	      .append("onclick=\"location.href='").append(baseUrl).append(totalPage).append("'\">")
	      .append("<span>맨마지막</span>")
	      .append("</button>");
	  }

	  return sb.toString();
	}

}
