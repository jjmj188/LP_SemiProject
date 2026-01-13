package product.controller;

import java.util.HashMap;
import java.util.List;
import java.util.Map;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import product.domain.ProductDTO;
import product.domain.ReviewDTO;
import product.domain.TrackDTO;
import product.model.ProductDAO;
import product.model.ProductDAO_imple;

public class ProductDetail extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String strProductNo = request.getParameter("productno");
		int productno = 0;
		
		try {
			productno = Integer.parseInt(strProductNo);
		} catch(NumberFormatException e) {
			super.setRedirect(true);
			super.setViewPage(request.getContextPath() + "/index.lp");
			return;
		}

		ProductDAO pdao = new ProductDAO_imple();
		
		ProductDTO pDto = pdao.selectOneProduct(productno);
		
		if(pDto == null) {
			String message = "존재하지 않는 상품입니다.";
			String loc = "javascript:history.back()"; // 뒤로 가기
			
			request.setAttribute("message", message);
			request.setAttribute("loc", loc);
			
			setRedirect(false);
			setViewPage("/WEB-INF/msg.jsp");
			return;
		}
		
		request.setAttribute("pDto", pDto);
		
		
		List<TrackDTO> trackList = pdao.selectTrackList(productno);
		request.setAttribute("trackList", trackList);
		
		// 3. 리뷰 리스트 조회 및 페이징
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 1;
        int sizePerPage = 5; 
        int blockSize = 5; // 리뷰는 블록 크기 5로 설정
        
        if (str_currentShowPageNo != null) {
            try { currentShowPageNo = Integer.parseInt(str_currentShowPageNo); } catch (Exception e) {}
        }
        
        int totalReviewCount = pdao.getTotalReviewCount(productno);
        int totalPage = (int) Math.ceil((double)totalReviewCount / sizePerPage);
        
        if (currentShowPageNo > totalPage && totalPage != 0) {
            currentShowPageNo = totalPage;
        }

        Map<String, String> paraMap = new HashMap<>();
        paraMap.put("productno", String.valueOf(productno));
        paraMap.put("currentShowPageNo", String.valueOf(currentShowPageNo));
        paraMap.put("sizePerPage", String.valueOf(sizePerPage));
        
        List<ReviewDTO> reviewList = pdao.selectReviewListPaging(paraMap);
        
        // 페이지바 생성
        String pageBar = makePageBar(currentShowPageNo, totalPage, blockSize, productno, request.getContextPath());
        request.setAttribute("pageBar", pageBar);
        
        request.setAttribute("reviewList", reviewList);
        request.setAttribute("totalReviewCount", totalReviewCount);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/productdetail.jsp");
    }

    // 리뷰용 페이지바 생성 메서드
    private String makePageBar(int currentShowPageNo, int totalPage, int blockSize, int productno, String ctxPath) {
        if (totalPage == 0) return "";

        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        int loop = 1;

        
        String url = ctxPath + "/productdetail.lp?productno=" + productno + "&currentShowPageNo=";
        String anchor = "#reviews";

        StringBuilder sb = new StringBuilder();

        sb.append("<li class='page-item'><button class='page-btn first' " + (currentShowPageNo == 1 ? "disabled" : "onclick=\"location.href='" + url + "1" + anchor + "'\"") + "><span>맨처음</span></button></li>");
        sb.append("<li class='page-item'><button class='page-btn prev' " + (currentShowPageNo == 1 ? "disabled" : "onclick=\"location.href='" + url + (currentShowPageNo - 1) + anchor + "'\"") + "><i class='fa-solid fa-chevron-left'></i></button></li>");

        while (!(loop > blockSize || pageNo > totalPage)) {
            if (pageNo == currentShowPageNo) {
                sb.append("<li class='page-item'><button class='page-num active'>" + pageNo + "</button></li>");
            } else {
                sb.append("<li class='page-item'><button class='page-num' onclick=\"location.href='" + url + pageNo + anchor + "'\">" + pageNo + "</button></li>");
            }
            loop++;
            pageNo++;
        }

        sb.append("<li class='page-item'><button class='page-btn next' " + (currentShowPageNo == totalPage ? "disabled" : "onclick=\"location.href='" + url + (currentShowPageNo + 1) + anchor + "'\"") + "><i class='fa-solid fa-chevron-right'></i></button></li>");
        sb.append("<li class='page-item'><button class='page-btn last' " + (currentShowPageNo == totalPage ? "disabled" : "onclick=\"location.href='" + url + totalPage + anchor + "'\"") + "><span>맨마지막</span></button></li>");

        return sb.toString();
    }

}
