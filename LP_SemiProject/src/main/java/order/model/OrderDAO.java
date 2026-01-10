package order.model;

import java.util.List;

import order.domain.CartDTO;
import order.domain.OrderDTO;

public interface OrderDAO {

	// 아래 메서드는 너가 구현해야 하는 DAO 메서드야 (밑에 예시 DAO 코드도 같이 줌)
	

	int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList)throws Exception;
}
