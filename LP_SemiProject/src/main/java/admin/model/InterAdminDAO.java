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
    
    // 7. 상품 전체 목록 조회 (카테고리명 포함)
    List<ProductVO> getProductList(Map<String, String> paraMap) throws SQLException;
    
    // 8. 주문 및 배송 전체 목록 조회 (페이징 처리는 생략, 전체 조회)
    List<Map<String, String>> getOrderList(Map<String, String> paraMap) throws SQLException;
    
}