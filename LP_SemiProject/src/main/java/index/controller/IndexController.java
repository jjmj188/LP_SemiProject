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

		// 카테고리 번호 받기
		String strCategoryNo = request.getParameter("categoryno");
		int categoryNo = 0; // 0 = 전체 보기

		if(strCategoryNo != null) {
			try {
				categoryNo = Integer.parseInt(strCategoryNo);
			} catch(NumberFormatException e) {
				categoryNo = 0; // 숫자가 아닌 값이 들어오면 전체 보기
			}
		}

		// 페이지 번호 받기
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
		
		// 전체 게시물 수 계산
		int totalCount = pdao.getTotalProductCount(categoryNo);
		
		int totalPage = (int) Math.ceil((double)totalCount / sizePerPage);
		
		if (currentShowPageNo > totalPage && totalPage != 0) {
			currentShowPageNo = totalPage;
		}
		
		// 상품 리스트 가져오기 (카테고리 번호 전달)
		List<ProductDTO> productList = null;
		if(totalCount > 0) {
			productList = pdao.selectPagingProduct(currentShowPageNo, sizePerPage, categoryNo);
		}

		request.setAttribute("productList", productList);
		request.setAttribute("totalPage", totalPage);
		request.setAttribute("currentPage", currentShowPageNo);
		
		request.setAttribute("categoryNo", categoryNo);

		// 최신상품 10개 조회 (상단 NEW 섹션용)
		List<ProductDTO> newProductList = pdao.selectNewProductList();
		request.setAttribute("newProductList", newProductList);
		
		setRedirect(false);
		setViewPage("/WEB-INF/index.jsp");
	}
}