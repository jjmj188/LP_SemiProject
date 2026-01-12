package product.controller;

import java.util.List;

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
		
		List<ReviewDTO> reviewList = pdao.selectReviewList(productno);
        request.setAttribute("reviewList", reviewList);
        
		super.setRedirect(false);
		super.setViewPage("/WEB-INF/productdetail.jsp");
		
	}

}
