package order.model;

import java.util.List;

import order.domain.CartDTO;
import order.domain.OrderDTO;

public interface OrderDAO {

	// 구매하기(저장, 업데이트)
	int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList, String[] cartnoArr)throws Exception;
}
