package order.model;

import java.util.List;

import order.domain.CartDTO;
import order.domain.OrderDTO;

public interface OrderDAO {

	// ✅ 선택 cartnoArr도 넘겨서 "선택한 것만 삭제"하도록
	int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList, String[] cartnoArr)throws Exception;
}
