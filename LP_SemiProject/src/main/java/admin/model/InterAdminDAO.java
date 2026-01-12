package admin.model;

import java.sql.SQLException;
import java.util.List;
import java.util.Map;

public interface InterAdminDAO {

    // 1. 오늘 매출 조회
    int getTodaySales() throws SQLException;
    
    // 2. 이번 달 매출 조회
    int getMonthSales() throws SQLException;
    
    // 3. 총 누적 매출 조회
    long getTotalSales() throws SQLException;
    
    // 4. 차트 데이터 조회
    List<Map<String, String>> getSalesChartData(Map<String, String> paraMap) throws SQLException;
    
    // 5. 관리자 로그인
    AdminVO getAdminLogin(Map<String, String> paraMap) throws SQLException;

    // 6. 회원 목록 조회 (검색 기능 포함 - 페이징 없음)
    List<MemberVO> getMemberList(Map<String, String> paraMap) throws SQLException;
    
    // 7. 회원 목록 조회 (페이징 처리)
    List<MemberVO> getMemberListWithPaging(Map<String, String> paraMap) throws SQLException;

    // 8. 총 회원 수 조회 (페이징 계산용)
    int getTotalMemberCount(Map<String, String> paraMap) throws SQLException;
    
    // 9. 회원 선택 탈퇴 처리 (status를 0으로 변경)
    int deleteMember(String[] userids) throws SQLException;
    
    // 10. 상품 전체 목록 조회 (카테고리명 포함 - 페이징 없음)
    List<ProductVO> getProductList(Map<String, String> paraMap) throws SQLException;

    // 11. 상품 전체 목록 개수 조회 (페이징 계산용)
    int getTotalProductCount(Map<String, String> paraMap) throws SQLException;

    // 12. 상품 전체 목록 조회 (페이징 처리)
    List<ProductVO> getProductListWithPaging(Map<String, String> paraMap) throws SQLException;
    
    // 13. 주문 및 배송 전체 목록 조회
    List<Map<String, String>> getOrderList(Map<String, String> paraMap) throws SQLException;
    
    // 14. 리뷰 전체 목록 조회
    List<Map<String, String>> getReviewList(Map<String, String> paraMap) throws SQLException;
    
    // 15. 질문 전체 목록 조회 
    List<InquiryVO> getInquiryList(Map<String, String> paraMap) throws SQLException;
    
    // 16. 상품 및 트랙 동시 등록 (트랜잭션 처리)
    int insertProductWithTracks(ProductVO pvo, String[] trackTitles) throws SQLException;

    // 17. 상품 정보 수정
    int updateProduct(ProductVO pvo) throws SQLException;

    // 18. 상품 선택 삭제 (트랙 포함 삭제)
    int deleteProduct(String[] pnums) throws SQLException;
    
    // 19. 배송 시작 처리 (송장번호, 택배사, 받는사람 수정 및 상태변경)
    int updateDeliveryStart(Map<String, String> paraMap) throws SQLException;

    // 20. 배송 완료 처리 
	int updateDeliveryEnd(String orderno) throws SQLException;

    // 21. 리뷰 작성 순서 처리 
    int deleteMultiReviews(String[] reviewNos) throws SQLException;
    
    // 22. 상품 전체 목록 조회 (페이징 계산용)
   	int getTotalReviewCount(Map<String, String> paraMap) throws SQLException;
   	
   	// 23. 상품 전체 목록 조회 (페이징 처리)
   	List<Map<String, String>> getReviewListWithPaging(Map<String, String> paraMap) throws SQLException;
    
    // 24. 문의내역 전체 목록 조회 (페이징 계산용)
   	int getTotalInquiryCount(Map<String, String> paraMap) throws SQLException;
   	
	// 25. 문의내역 전체 목록 조회 (페이징 처리)
   	List<InquiryVO> getInquiryListWithPaging(Map<String, String> paraMap) throws SQLException;
   	
    // 26. 문의 내역 답변 등록 (상태 변경 포함)
    int replyInquiry(String inquiryno, String adminreply) throws SQLException;

}