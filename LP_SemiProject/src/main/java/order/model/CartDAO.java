package order.model;

import java.sql.SQLException;

public interface CartDAO {

	// DB 처리 (있으면 update, 없으면 insert)
	int addCart(String loginuserid, int productno, int qty)throws SQLException;
	
}
