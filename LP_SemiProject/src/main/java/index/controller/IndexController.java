package index.controller;

import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import product.domain.ProductDTO;
import product.model.ProductDAO;
import product.model.ProductDAO_imple;

public class IndexController extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		ProductDAO pdao = new ProductDAO_imple();

		String strPageNo = request.getParameter("pageNo");
		int currentShowPageNo = 1;
		int sizePerPage = 8;
		
		if(strPageNo != null) {
			try {
				currentShowPageNo = Integer.parseInt(strPageNo);
			} catch(NumberFormatException e) {
				currentShowPageNo = 1;
			}
		}
		
		// 전체 페이지 수 계산
		int totalCount = pdao.getTotalProductCount();
		int totalPage = (int) Math.ceil((double)totalCount / sizePerPage);
		
		if (currentShowPageNo > totalPage && totalPage != 0) {
			currentShowPageNo = totalPage;
		}
		
		// 상품 리스트 가져오기
		List<ProductDTO> productList = null;
		if(totalCount > 0) {
			productList = pdao.selectPagingProduct(currentShowPageNo, sizePerPage);
		}

		request.setAttribute("productList", productList);
		request.setAttribute("totalPage", totalPage);
		request.setAttribute("currentPage", currentShowPageNo);

		setRedirect(false);
		setViewPage("/WEB-INF/index.jsp");
	}
}