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

    // 6. 회원 목록 조회 (검색 기능 포함)
    List<MemberVO> getMemberList(Map<String, String> paraMap) throws SQLException;
    
    // 7. 회원 선택 탈퇴 처리 (status를 0으로 변경)
    int deleteMember(String[] userids) throws SQLException;
    
    // 8. 상품 전체 목록 조회 (카테고리명 포함)
    List<ProductVO> getProductList(Map<String, String> paraMap) throws SQLException;
    
    // 9. 주문 및 배송 전체 목록 조회
    List<Map<String, String>> getOrderList(Map<String, String> paraMap) throws SQLException;
    
    // 10. 리뷰 전체 목록 조회
    List<Map<String, String>> getReviewList(Map<String, String> paraMap) throws SQLException;
    
    // 11. 질문 전체 목록 조회 
    List<InquiryVO> getInquiryList(Map<String, String> paraMap) throws SQLException;
    
    // 12. 상품 및 트랙 동시 등록 (트랜잭션 처리)
    int insertProductWithTracks(ProductVO pvo, String[] trackTitles) throws SQLException;

    // 13. 상품 정보 수정
    int updateProduct(ProductVO pvo) throws SQLException;

    // 14. 상품 선택 삭제 (트랙 포함 삭제)
    int deleteProduct(String[] pnums) throws SQLException;

    // 15. 문의 내역 답변 등록 (상태 변경 포함)
    int replyInquiry(String inquiryno, String adminreply) throws SQLException;

}