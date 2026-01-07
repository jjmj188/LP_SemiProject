package order.model;

import java.sql.SQLException;
import java.util.List;

import order.domain.CartDTO;

public interface CartDAO {

	// DB 처리 (있으면 update, 없으면 insert)
	int addCart(String loginuserid, int productno, int qty)throws SQLException;

	//장바구니 조회
	List<CartDTO> selectCartList(String userid)throws SQLException;
	
}
