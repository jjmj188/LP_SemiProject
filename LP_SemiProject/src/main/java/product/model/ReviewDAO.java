package product.model;

import java.sql.SQLException;

import order.domain.OrderDetailDTO;

public interface ReviewDAO {

	//  (로그인유저, 주문번호, 상품번호)로 "내가 산 상품"인지 DB 검증 + 표시 정보 조회
	OrderDetailDTO selectOrderItemForReview(String userid, int orderno, int productno)throws SQLException;

	// 이미 리뷰 작성했으면 막기
	boolean existsReview(String userid, int productno, int orderno)throws SQLException;

	// 구매 검증 (내 주문의 상품인지)
	boolean isPurchasedItem(String userid, int orderno, int productno)throws SQLException;

	// 리뷰 등록
	int insertReview(String userid, int productno, int orderno, int rating, String reviewcontent)throws SQLException;

}
