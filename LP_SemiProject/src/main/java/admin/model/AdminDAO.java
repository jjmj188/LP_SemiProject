package admin.model;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

public class AdminDAO implements InterAdminDAO {

    private DataSource ds; 
    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;

    public AdminDAO() {
        try {
            Context initContext = new InitialContext();
            Context envContext  = (Context)initContext.lookup("java:comp/env"); // /를 빼는 것이 표준입니다.
            ds = (DataSource)envContext.lookup("SemiProject"); 
        } catch(NamingException e) {
            e.printStackTrace();
        }
    }

    private void close() {
        try {
            if(rs != null)    { rs.close();    rs = null; }
            if(pstmt != null) { pstmt.close(); pstmt = null; }
            if(conn != null)  { conn.close();  conn = null; }
        } catch(SQLException e) {
            e.printStackTrace();
        }
    }

    // 1. 오늘 매출
    @Override
    public int getTodaySales() throws SQLException {
        int todaySales = 0;
        try {
            conn = ds.getConnection();
            
            String sql = " SELECT nvl(SUM(A.totalprice), 0) "
                       + " FROM tbl_order A JOIN tbl_delivery B "
                       + " ON A.orderno = B.fk_orderno "
                       + " WHERE to_char(A.orderdate, 'yyyy-mm-dd') = to_char(sysdate, 'yyyy-mm-dd') "
                       + " AND B.deliverystatus IN ('배송준비중', '배송중', '배송완료') "; 
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                todaySales = rs.getInt(1);
            }
        } finally {
            close();
        }
        return todaySales;
    }

    // 2. 이번 달 매출
    @Override
    public int getMonthSales() throws SQLException {
        int monthSales = 0;
        try {
            conn = ds.getConnection();
            
            String sql = " SELECT nvl(SUM(A.totalprice), 0) "
                       + " FROM tbl_order A JOIN tbl_delivery B "
                       + " ON A.orderno = B.fk_orderno "
                       + " WHERE to_char(A.orderdate, 'yyyy-mm') = to_char(sysdate, 'yyyy-mm') "
                       + " AND B.deliverystatus IN ('배송준비중', '배송중', '배송완료') ";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                monthSales = rs.getInt(1);
            }
        } finally {
            close();
        }
        return monthSales;
    }

    // 3. 누적 매출
    @Override
    public long getTotalSales() throws SQLException {
        long totalSales = 0;
        try {
            conn = ds.getConnection();
            
            String sql = " SELECT nvl(SUM(A.totalprice), 0) "
                       + " FROM tbl_order A JOIN tbl_delivery B "
                       + " ON A.orderno = B.fk_orderno "
                       + " WHERE B.deliverystatus IN ('배송준비중', '배송중', '배송완료') ";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            if (rs.next()) {
                totalSales = rs.getLong(1);
            }
        } finally {
            close();
        }
        return totalSales;
    }

    // 4. 차트용 데이터 조회
    @Override
    public List<Map<String, String>> getSalesChartData(Map<String, String> paraMap) throws SQLException {
        List<Map<String, String>> chartList = new ArrayList<>();
        try {
            conn = ds.getConnection();
            String searchType = paraMap.get("searchType");
            String sql = "";
            
            if("month".equals(searchType)) {
                sql = " SELECT to_char(A.orderdate, 'yyyy-mm') AS label, "
                    + "        nvl(sum(A.totalprice), 0) AS amount "
                    + " FROM tbl_order A JOIN tbl_delivery B "
                    + " ON A.orderno = B.fk_orderno "
                    + " WHERE to_char(A.orderdate, 'yyyy-mm') BETWEEN ? AND ? "
                    + "   AND B.deliverystatus IN ('배송준비중', '배송중', '배송완료') "
                    + " GROUP BY to_char(A.orderdate, 'yyyy-mm') "
                    + " ORDER BY label ASC ";
                    
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, paraMap.get("startDate"));
                pstmt.setString(2, paraMap.get("endDate"));
            } 
            else {
                sql = " SELECT to_char(A.orderdate, 'yyyy') AS label, "
                    + "        nvl(sum(A.totalprice), 0) AS amount "
                    + " FROM tbl_order A JOIN tbl_delivery B "
                    + " ON A.orderno = B.fk_orderno "
                    + " WHERE to_char(A.orderdate, 'yyyy') BETWEEN ? AND ? "
                    + "   AND B.deliverystatus IN ('배송준비중', '배송중', '배송완료') "
                    + " GROUP BY to_char(A.orderdate, 'yyyy') "
                    + " ORDER BY label ASC ";
                    
                pstmt = conn.prepareStatement(sql);
                pstmt.setString(1, paraMap.get("startYear"));
                pstmt.setString(2, paraMap.get("endYear"));
            }
            
            rs = pstmt.executeQuery();
            while(rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("label", rs.getString("label"));
                map.put("amount", rs.getString("amount"));
                chartList.add(map);
            }
        } finally {
            close();
        }
        return chartList;
    }
    
    // 5. 관리자 로그인 처리
    @Override
    public AdminVO getAdminLogin(Map<String, String> paraMap) throws SQLException {
        AdminVO adminvo = null;
    
        try {
            conn = ds.getConnection();
    
            String sql = " SELECT adminid "
                       + " FROM tbl_admin "
                       + " WHERE adminid = ? AND adminpwd = ? ";
    
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, paraMap.get("adminid"));
            pstmt.setString(2, paraMap.get("adminpwd")); 
    
            rs = pstmt.executeQuery();
    
            if (rs.next()) {
                adminvo = new AdminVO();
                adminvo.setAdminid(rs.getString("adminid"));
            }
    
        } finally {
            close();
        }
    
        return adminvo;
    }

    // 6. 회원 전체 목록 조회 (검색 기능 포함)
    @Override
    public List<MemberVO> getMemberList(Map<String, String> paraMap) throws SQLException {
        
        List<MemberVO> memberList = new ArrayList<>();
        
        try {
            conn = ds.getConnection();
            
            String searchWord = paraMap.get("searchWord");
            
            String sql = " SELECT userseq, userid, name, email, "
                       + "        mobile, gender, "
                       + "        to_char(registerday, 'yyyy-mm-dd') AS registerday, "
                       + "        status, idle "
                       + " FROM tbl_member "
                       + " WHERE userid != 'admin' "; // 관리자 계정 제외
            
            // 검색어가 들어왔을 경우
            if(searchWord != null && !searchWord.trim().isEmpty()) {
                sql += " AND (userid like '%'|| ? ||'%' OR name like '%'|| ? ||'%') ";
            }
            
            sql += " ORDER BY userseq DESC "; // 최신순
            
            pstmt = conn.prepareStatement(sql);
            
            if(searchWord != null && !searchWord.trim().isEmpty()) {
                pstmt.setString(1, searchWord);
                pstmt.setString(2, searchWord);
            }
            
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                MemberVO mvo = new MemberVO();
                
                mvo.setUserseq(rs.getInt("userseq"));
                mvo.setUserid(rs.getString("userid"));
                mvo.setName(rs.getString("name"));
                mvo.setEmail(rs.getString("email"));
                mvo.setMobile(rs.getString("mobile"));
                mvo.setGender(rs.getString("gender"));
                mvo.setRegisterday(rs.getString("registerday"));
                mvo.setStatus(rs.getInt("status"));
                mvo.setIdle(rs.getInt("idle"));
                
                memberList.add(mvo);
            }
            
        } finally {
            close();
        }
        
        return memberList;
    }
    
    // 7. 상품 전체 목록 조회 구현
    @Override
    public List<ProductVO> getProductList(Map<String, String> paraMap) throws SQLException {
        List<ProductVO> productList = new ArrayList<>();
        
        try {
            conn = ds.getConnection();
            
            // 카테고리 이름을 함께 가져오기 위해 JOIN 사용
            String sql = " SELECT P.productno, P.fk_categoryno, P.productname, P.productimg, "
                       + "        P.price, P.stock, to_char(P.registerday, 'yyyy-mm-dd') as registerday, "
                       + "        C.categoryname "
                       + " FROM tbl_product P "
                       + " JOIN tbl_category C ON P.fk_categoryno = C.categoryno "
                       + " ORDER BY P.productno DESC ";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                ProductVO pvo = new ProductVO();
                pvo.setProductno(rs.getInt("productno"));
                pvo.setFk_categoryno(rs.getInt("fk_categoryno"));
                pvo.setProductname(rs.getString("productname"));
                pvo.setProductimg(rs.getString("productimg"));
                pvo.setPrice(rs.getInt("price"));
                pvo.setStock(rs.getInt("stock"));
                pvo.setRegisterday(rs.getString("registerday"));
                pvo.setCategoryname(rs.getString("categoryname")); // 조인된 컬럼
                
                productList.add(pvo);
            }
            
        } finally {
            close();
        }
        
        return productList;
    }
    
 // 8. 주문 전체 목록 조회 (수정됨: 주소 정보를 Member 테이블에서 가져옴)
    @Override
    public List<Map<String, String>> getOrderList(Map<String, String> paraMap) throws SQLException {
        List<Map<String, String>> orderList = new ArrayList<>();
        
        try {
            conn = ds.getConnection();
            
            // [핵심 수정 사항]
            // D.address (X) -> M.address (O)
            // 배송 테이블(D)에 주소가 없으니, 회원 테이블(M)의 주소 정보를 가져옵니다.
            String sql = " SELECT O.orderno, M.name, M.mobile, M.email, "
                       + "        M.postcode, M.address, M.detailaddress, M.extraaddress, " 
                       + "        O.totalprice, D.deliverystatus "
                       + " FROM tbl_order O "
                       + " JOIN tbl_member M ON O.fk_userid = M.userid "
                       + " JOIN tbl_delivery D ON O.orderno = D.fk_orderno "
                       + " ORDER BY O.orderno DESC ";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("orderno", rs.getString("orderno"));
                map.put("name", rs.getString("name"));
                map.put("mobile", rs.getString("mobile"));
                map.put("email", rs.getString("email"));
                
                // 회원 테이블(M)에서 가져온 주소 정보 저장
                map.put("postcode", rs.getString("postcode"));
                map.put("address", rs.getString("address"));
                map.put("detailaddress", rs.getString("detailaddress"));
                map.put("extraaddress", rs.getString("extraaddress"));
                
                map.put("totalprice", rs.getString("totalprice"));
                map.put("deliverystatus", rs.getString("deliverystatus"));
                
                // 상품명 임시 지정
                map.put("productname", "LP 상품"); 
                
                orderList.add(map);
            }
            
        } finally {
            close();
        }
        
        return orderList;
    }
    
}