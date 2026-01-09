package order.model;

import java.sql.SQLException;
import java.util.List;

import order.domain.CartDTO;

public interface CartDAO {

	// DB 처리 (있으면 update, 없으면 insert)
	int addCart(String loginuserid, int productno, int qty)throws SQLException;

	//장바구니 조회
	List<CartDTO> selectCartList(String userid)throws SQLException;

	//장바구니 수정
	int updateCartQty(String loginuserid, int cartno, int qty)throws SQLException;
	
	//장바구니 개별 삭제
	int deleteSelected(String userid, String[] cartnoArr)throws SQLException;

	//장바구니 전체삭제
	int deleteAll(String userid)throws SQLException;

	
}
