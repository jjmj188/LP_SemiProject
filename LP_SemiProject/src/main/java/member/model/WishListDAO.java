package member.model;

import java.sql.SQLException;
import java.util.List;
import product.domain.ProductDTO;

public interface WishListDAO {
	// 1. 찜 추가/삭제 토글 (리턴: 1=찜추가, 0=찜삭제)
    int toggleWishList(String userid, int productno) throws SQLException;

    // 2. 찜 여부 확인 (1:찜함, 0:안함)
    int checkWishStatus(String userid, int productno) throws SQLException;
    
    // 3. 내 찜 목록 조회 (마이페이지용)
    List<ProductDTO> selectWishList(String userid) throws SQLException;
	
}
