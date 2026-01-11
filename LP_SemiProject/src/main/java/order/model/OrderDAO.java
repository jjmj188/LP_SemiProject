package order.model;

import java.util.List;

import order.domain.CartDTO;
import order.domain.OrderDTO;
import order.domain.OrderDetailDTO;

public interface OrderDAO {

	// 구매하기(저장, 업데이트)
	int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList, String[] cartnoArr)throws Exception;

	
	
	
	// 구매내역 "주문 카드" 목록 (주문 단위)
    List<OrderDTO> selectMyOrderList(String userid) throws Exception;

    // 구매내역 "펼치기" 상세 (주문번호 1건)
    List<OrderDetailDTO> selectMyOrderDetailList(int orderno, String userid) throws Exception;

    //주문주소 + 배송정보(송장) 조회
	OrderDTO selectTrackingInfo(int orderno, String userid)throws Exception;
}
