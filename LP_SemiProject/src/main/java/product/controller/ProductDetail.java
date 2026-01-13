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
		
		// 리뷰 리스트 조회 5개씩
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        
        int currentShowPageNo = 0; // 현재 페이지 번호
        int sizePerPage = 5;       // 한 페이지당 보여줄 리뷰 개수 (5개)
        int totalReviewCount = 0;  // 총 리뷰 개수
        int totalPage = 0;         // 총 페이지 수
        
        // 총 리뷰 개수 구하기
        totalReviewCount = pdao.getTotalReviewCount(productno);
        
        // 총 페이지 수 계산
        totalPage = (int) Math.ceil((double)totalReviewCount / sizePerPage);
        
        // 현재 페이지 번호 설정
        if (str_currentShowPageNo == null) {
            currentShowPageNo = 1;
        } else {
            try {
                currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
                if(currentShowPageNo < 1 || (totalPage > 0 && currentShowPageNo > totalPage)) {
                    currentShowPageNo = 1;
                }
            } catch (NumberFormatException e) {
                currentShowPageNo = 1;
            }
        }
        
        if(totalPage == 0) currentShowPageNo = 1; // 리뷰가 없어도 1페이지로 설정

        Map<String, String> paraMap = new HashMap<>();
        paraMap.put("productno", String.valueOf(productno));
        paraMap.put("currentShowPageNo", String.valueOf(currentShowPageNo));
        paraMap.put("sizePerPage", String.valueOf(sizePerPage));
        
        List<ReviewDTO> reviewList = pdao.selectReviewListPaging(paraMap);
        
        // JSP로 데이터 전달
        request.setAttribute("reviewList", reviewList);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("currentShowPageNo", currentShowPageNo);
        request.setAttribute("totalReviewCount", totalReviewCount);
        // --------------------------------------------------------------------
        
		super.setRedirect(false);
		super.setViewPage("/WEB-INF/productdetail.jsp");
		
	}

}
