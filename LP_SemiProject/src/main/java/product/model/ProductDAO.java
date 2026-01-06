package product.model;

import java.sql.SQLException;
import java.util.List;

import product.domain.TrackDTO;
import product.domain.ProductDTO;

public interface ProductDAO {
	
	// 페이징 처리용 전체상품 조회
	int getTotalProductCount() throws SQLException;
	
	// 페이지 번호에 해당하는 상품 리스트(8개)를 가져오는 메소드
	List<ProductDTO> selectPagingProduct(int currentShowPageNo, int sizePerPage) throws SQLException;

	// 제품 상세 보기(1개 조회)
	ProductDTO selectOneProduct(int productno) throws SQLException;

	// 곡 리스트 조회
	List<TrackDTO> selectTrackList(int productno) throws SQLException;

	
	
	
	
}
