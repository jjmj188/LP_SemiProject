package my_info.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.OrderDTO;
import order.domain.OrderDetailDTO;
import order.model.OrderDAO;
import order.model.OrderDAO_imple;

public class My_order extends AbstractController {

    private OrderDAO odao = new OrderDAO_imple();

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
    	            request.setAttribute("message", "로그인 후 이용 가능합니다.");
    	            request.setAttribute("loc", request.getContextPath() + "/login/login.lp");
    	            setRedirect(false);
    	            setViewPage("/WEB-INF/msg.jsp");
    	            return;
    	        }

    	        String userid = loginuser.getUserid();

    	        // 페이징 변수 설정
    	        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
    	        int currentShowPageNo = 1;
    	        int sizePerPage = 3;  // 한 페이지에 표시할 주문 개수 (3개로 설정)
    	        int blockSize = 10;   // 페이지바에 표시할 페이지 번호 블록 크기 (10개 페이지 번호)

    	        if (str_currentShowPageNo != null) {
    	            try {
    	                currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
    	            } catch (Exception e) {}
    	        }

    	        // 총 주문 수 계산
    	        int totalCount = odao.getTotalOrderCount(userid);  // 주문 목록의 총 개수 구하기
    	        int totalPage = (int) Math.ceil((double) totalCount / sizePerPage);  // 총 페이지 수 계산

    	        // currentShowPageNo가 totalPage보다 크면 totalPage로 설정
    	        if (currentShowPageNo > totalPage && totalPage != 0) {
    	            currentShowPageNo = totalPage;
    	        }

    	        //주문 목록 조회 (페이징 처리)
    	        int startRow = (currentShowPageNo - 1) * sizePerPage;
    	        List<OrderDTO> orderList = odao.selectMyOrderListPaging(userid, startRow, sizePerPage);  // 페이징된 주문 목록 가져오기

    	        // 각 주문에 대한 주문 상세 정보 추가
    	        if (orderList != null) {
    	            for (OrderDTO o : orderList) {
    	                List<OrderDetailDTO> detailList = odao.selectMyOrderDetailList(o.getOrderno(), userid);
    	                o.setOrderDetailList(detailList);
    	            }
    	        }

    	        // 5) 페이지바 생성 (makePageBar 호출)
    	        String pageBar = makePageBar(currentShowPageNo, totalPage, blockSize, request.getContextPath());
    	        request.setAttribute("pageBar", pageBar);

    	        // 6) JSP에 필요한 정보 전달
    	        request.setAttribute("orderList", orderList);
    	        request.setAttribute("totalPage", totalPage);
    	        request.setAttribute("currentShowPageNo", currentShowPageNo);
    	        request.setAttribute("totalCount", totalCount);

    	        setRedirect(false);
    	        setViewPage("/WEB-INF/my_info/my_order.jsp");
    	    }

    	    // 페이지바 생성 메서드
    	    private String makePageBar(int currentShowPageNo, int totalPage, int blockSize, String ctxPath) {
    	        if (totalPage == 0) return "";  // 총 페이지가 없으면 빈 문자열 반환

    	        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
    	        int loop = 1;
    	        StringBuilder sb = new StringBuilder();

    	        // [맨처음]
    	        if (currentShowPageNo == 1) {
    	            sb.append("<li class='page-item'><button class='page-btn first' disabled><span>맨처음</span></button></li>");
    	        } else {
    	            sb.append("<li class='page-item'><button class='page-btn first' onclick='goPage(1)'><span>맨처음</span></button></li>");
    	        }

    	        // [이전]
    	        if (currentShowPageNo == 1) {
    	            sb.append("<li class='page-item'><button class='page-btn prev' disabled><i class='fa-solid fa-chevron-left'></i></button></li>");
    	        } else {
    	            sb.append("<li class='page-item'><button class='page-btn prev' onclick='goPage(" + (currentShowPageNo - 1) + ")'><i class='fa-solid fa-chevron-left'></i></button></li>");
    	        }

    	        // [페이지 번호]
    	        while (!(loop > blockSize || pageNo > totalPage)) {
    	            if (pageNo == currentShowPageNo) {
    	                sb.append("<li class='page-item'><button class='page-num active'>" + pageNo + "</button></li>");
    	            } else {
    	                sb.append("<li class='page-item'><button class='page-num' onclick='goPage(" + pageNo + ")'>" + pageNo + "</button></li>");
    	            }
    	            loop++;
    	            pageNo++;
    	        }

    	        // [다음]
    	        if (currentShowPageNo == totalPage) {
    	            sb.append("<li class='page-item'><button class='page-btn next' disabled><i class='fa-solid fa-chevron-right'></i></button></li>");
    	        } else {
    	            sb.append("<li class='page-item'><button class='page-btn next' onclick='goPage(" + (currentShowPageNo + 1) + ")'><i class='fa-solid fa-chevron-right'></i></button></li>");
    	        }

    	        // [맨마지막]
    	        if (currentShowPageNo == totalPage) {
    	            sb.append("<li class='page-item'><button class='page-btn last' disabled><span>맨마지막</span></button></li>");
    	        } else {
    	            sb.append("<li class='page-item'><button class='page-btn last' onclick='goPage(" + totalPage + ")'><span>맨마지막</span></button></li>");
    	        }

    	        return sb.toString();
    	    
    }
}
