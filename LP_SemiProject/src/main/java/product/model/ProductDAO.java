package product.model;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

import product.domain.TrackDTO;
import product.domain.ProductDTO;
import product.domain.ReviewDTO;

public interface ProductDAO {
	
	// 페이징 처리용 전체상품 조회
	int getTotalProductCount(int categoryNo, String searchWord) throws SQLException;
	
	// 페이지 번호에 해당하는 상품 리스트(8개)를 가져오는 메소드
	List<ProductDTO> selectPagingProduct(int currentShowPageNo, int sizePerPage, int categoryNo, String searchWord, String sortType) throws SQLException;

	// 제품 상세 보기(1개 조회)
	ProductDTO selectOneProduct(int productno) throws SQLException;

	// 곡 리스트 조회
	List<TrackDTO> selectTrackList(int productno) throws SQLException;

	// NEW 제품 조회(최신순으로 10개)
	List<ProductDTO> selectNewProductList() throws SQLException;
	
	// 로그아웃 상태용 랜덤추천 : 각 카테고리별로 1개씩 총 5개 랜덤 추출
    List<ProductDTO> selectRandomRecommendation() throws SQLException;

    // 로그인 상태용 랜덤추천 : 특정 카테고리에서 지정된 개수(count)만큼 랜덤 추출
    List<ProductDTO> selectProductsByCategory(int categoryNo, int count) throws SQLException;
    
    
    // 페이징 처리된 리뷰 목록 (5개씩)
    List<ReviewDTO> selectReviewListPaging(Map<String, String> paraMap) throws SQLException;
    
    // 특정 제품의 리뷰 총 개수 (페이징 계산용)
    int getTotalReviewCount(int productno) throws SQLException;
}
