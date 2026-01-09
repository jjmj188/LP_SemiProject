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

// 암호화/복호화 유틸
import util.security.AES256;
import util.security.SecretMyKey;

public class AdminDAO implements InterAdminDAO {

    private DataSource ds; 
    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;
    
    // 암호화/복호화 객체
    private AES256 aes;

    // 생성자
    public AdminDAO() {
        try {
            Context initContext = new InitialContext();
            Context envContext  = (Context)initContext.lookup("java:/comp/env");
            
            ds = (DataSource)envContext.lookup("SemiProject");
            
            aes = new AES256(SecretMyKey.KEY); 
            
        } catch(NamingException e) {
            e.printStackTrace();
        } catch(Exception e) {
            e.printStackTrace();
        }
    }

    // 자원 반납
    private void close() {
        try {
            if(rs != null)    { rs.close();    rs = null; }
            if(pstmt != null) { pstmt.close(); pstmt = null; }
            if(conn != null)  { conn.close();  conn = null; }
        } catch(SQLException e) {
            e.printStackTrace();
        }
    }

    // 1. 오늘 매출 조회
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

    // 2. 이번 달 매출 조회
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

    // 3. 총 누적 매출 조회
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

    // 4. 차트용 데이터 조회 (월별/연도별)
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
    
    // 5. 관리자 로그인
    @Override
    public AdminVO getAdminLogin(Map<String, String> paraMap) throws SQLException {
        AdminVO adminvo = null;
        try {
            conn = ds.getConnection();
            String sql = " SELECT adminid FROM tbl_admin WHERE adminid = ? AND adminpwd = ? ";
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

    // 6. 회원 전체 목록 조회 (복호화 로직 포함)
    @Override
    public List<MemberVO> getMemberList(Map<String, String> paraMap) throws SQLException {
        List<MemberVO> memberList = new ArrayList<>();
        try {
            conn = ds.getConnection();
            String searchWord = paraMap.get("searchWord");
            String sql = " SELECT userseq, userid, name, email, mobile, gender, "
                       + "        to_char(registerday, 'yyyy-mm-dd') AS registerday, status, idle "
                       + " FROM tbl_member "
                       + " WHERE userid != 'admin' "; 
            
            if(searchWord != null && !searchWord.trim().isEmpty()) {
                sql += " AND (userid like '%'|| ? ||'%' OR name like '%'|| ? ||'%') ";
            }
            sql += " ORDER BY userseq DESC ";
            
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
                
                try {
                    String encEmail = rs.getString("email");
                    if(encEmail != null) mvo.setEmail(aes.decrypt(encEmail));
                    else mvo.setEmail("");
                } catch(Exception e) {
                    mvo.setEmail(rs.getString("email"));
                }

                try {
                    String encMobile = rs.getString("mobile");
                    if(encMobile != null) mvo.setMobile(aes.decrypt(encMobile));
                    else mvo.setMobile("");
                } catch(Exception e) {
                    mvo.setMobile(rs.getString("mobile"));
                }
                
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
    
    // 7. 회원 선택 탈퇴 처리 (Batch 처리)
    @Override
    public int deleteMember(String[] userids) throws SQLException {
        int result = 0;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            
            String sql = " UPDATE tbl_member SET status = 0 WHERE userid = ? ";
            pstmt = conn.prepareStatement(sql);
            
            for(String userid : userids) {
                pstmt.setString(1, userid);
                pstmt.addBatch(); 
            }
            
            int[] count = pstmt.executeBatch();
            
            for(int n : count) {
                if(n == 1) result++; 
            }
            
            if(result == userids.length) {
                conn.commit();
            } else {
                conn.rollback();
                result = 0;
            }
            conn.setAutoCommit(true);
            
        } catch(SQLException e) {
            try { if(conn != null) conn.rollback(); } catch(SQLException ex) {}
            e.printStackTrace();
        } finally {
            close();
        }
        return result;
    }

    // 8. 상품 전체 목록 조회
    @Override
    public List<ProductVO> getProductList(Map<String, String> paraMap) throws SQLException {
        List<ProductVO> productList = new ArrayList<>();
        try {
            conn = ds.getConnection();
            String sql = " SELECT P.productno, P.fk_categoryno, P.productname, P.productimg, "
                       + "        P.price, P.stock, to_char(P.registerday, 'yyyy-mm-dd') as registerday, "
                       + "        P.point, C.categoryname "
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
                pvo.setPoint(rs.getInt("point"));
                pvo.setCategoryname(rs.getString("categoryname")); 
                productList.add(pvo);
            }
        } finally {
            close();
        }
        return productList;
    }
    
    // 9. 상품 및 트랙 동시 등록 메소드 (Transaction + Batch 처리)
    @Override
    public int insertProductWithTracks(ProductVO pvo, String[] trackTitles) throws SQLException {
        int result = 0;
        
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false); 
            
            String seqSql = " SELECT seq_productno.nextval FROM dual ";
            pstmt = conn.prepareStatement(seqSql);
            rs = pstmt.executeQuery();
            
            int productNo = 0;
            if(rs.next()) {
                productNo = rs.getInt(1);
            }
            rs.close();
            pstmt.close();
            
            String productSql = " INSERT INTO tbl_product(productno, fk_categoryno, productname, productimg, price, stock, productdesc, point, youtubeurl, registerday) "
                              + " VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, sysdate) ";
            
            pstmt = conn.prepareStatement(productSql);
            pstmt.setInt(1, productNo);
            pstmt.setInt(2, pvo.getFk_categoryno());
            pstmt.setString(3, pvo.getProductname());
            pstmt.setString(4, pvo.getProductimg());
            pstmt.setInt(5, pvo.getPrice());
            pstmt.setInt(6, pvo.getStock());
            pstmt.setString(7, pvo.getProductdesc());
            pstmt.setInt(8, pvo.getPoint());
            pstmt.setString(9, pvo.getYoutubeurl());
            
            int n1 = pstmt.executeUpdate();
            pstmt.close();
            
            int n2 = 1; 
            
            if(trackTitles != null && trackTitles.length > 0) {
                
                String trackSql = " INSERT INTO tbl_track(trackno, fk_productno, track_order, track_title) "
                                + " VALUES (seq_trackno.nextval, ?, ?, ?) ";
                
                pstmt = conn.prepareStatement(trackSql);
                
                int batchCount = 0;
                
                for(int i=0; i<trackTitles.length; i++) {
                    if(trackTitles[i] != null && !trackTitles[i].trim().isEmpty()) {
                        pstmt.setInt(1, productNo);
                        pstmt.setInt(2, i + 1);
                        pstmt.setString(3, trackTitles[i]);
                        
                        pstmt.addBatch();
                        batchCount++;
                    }
                }
                
                if(batchCount > 0) {
                    int[] resultArr = pstmt.executeBatch();
                    for(int res : resultArr) {
                        if(res == -3) { 
                            n2 = 0;
                            break; 
                        }
                    }
                }
            }
            
            if(n1 == 1 && n2 == 1) {
                conn.commit();
                result = 1;
            } else {
                conn.rollback();
                result = 0;
            }
            
        } catch (SQLException e) {
            if(conn != null) conn.rollback();
            e.printStackTrace();
            throw e;
        } finally {
            if(conn != null) conn.setAutoCommit(true);
            close();
        }
        
        return result;
    }
    
    // 10. 상품 정보 수정 (Update)
    @Override
    public int updateProduct(ProductVO pvo) throws SQLException {
        int result = 0;
        try {
            conn = ds.getConnection();
            
            String sql = " UPDATE tbl_product SET "
                       + " fk_categoryno = ?, productname = ?, price = ?, stock = ?, "
                       + " point = ?, youtubeurl = ?, productdesc = ? ";
            
            if(pvo.getProductimg() != null) {
                sql += " , productimg = ? ";
            }
            
            sql += " WHERE productno = ? ";
            
            pstmt = conn.prepareStatement(sql);
            
            pstmt.setInt(1, pvo.getFk_categoryno());
            pstmt.setString(2, pvo.getProductname());
            pstmt.setInt(3, pvo.getPrice());
            pstmt.setInt(4, pvo.getStock());
            pstmt.setInt(5, pvo.getPoint());
            pstmt.setString(6, pvo.getYoutubeurl());
            pstmt.setString(7, pvo.getProductdesc());
            
            if(pvo.getProductimg() != null) {
                pstmt.setString(8, pvo.getProductimg());
                pstmt.setInt(9, pvo.getProductno());
            } else {
                pstmt.setInt(8, pvo.getProductno());
            }
            
            result = pstmt.executeUpdate();
            
        } finally {
            close();
        }
        return result;
    }

    // 11. 상품 선택 삭제 (Delete - 트랙도 같이 삭제)
    @Override
    public int deleteProduct(String[] pnums) throws SQLException {
        int result = 0;
        try {
            conn = ds.getConnection();
            conn.setAutoCommit(false);
            
            String sqlTrack = " DELETE FROM tbl_track WHERE fk_productno = ? ";
            pstmt = conn.prepareStatement(sqlTrack);
            
            for(String pnum : pnums) {
                pstmt.setString(1, pnum);
                pstmt.addBatch();
            }
            pstmt.executeBatch();
            pstmt.close();
            
            String sqlProduct = " DELETE FROM tbl_product WHERE productno = ? ";
            pstmt = conn.prepareStatement(sqlProduct);
            
            for(String pnum : pnums) {
                pstmt.setString(1, pnum);
                pstmt.addBatch();
            }
            int[] cnt = pstmt.executeBatch();
            
            boolean flag = true;
            for(int n : cnt) {
                if(n == PreparedStatement.EXECUTE_FAILED) {
                    flag = false; break;
                }
            }
            
            if(flag) {
                conn.commit();
                result = 1;
            } else {
                conn.rollback();
                result = 0;
            }
            
            conn.setAutoCommit(true);
            
        } catch(SQLException e) {
            try { if(conn != null) conn.rollback(); } catch(SQLException ex) {}
            e.printStackTrace();
        } finally {
            close();
        }
        return result;
    }

    // 12. 주문 및 배송 전체 목록 조회
    @Override
    public List<Map<String, String>> getOrderList(Map<String, String> paraMap) throws SQLException {
        List<Map<String, String>> orderList = new ArrayList<>();
        try {
            conn = ds.getConnection();
            
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
                
                map.put("postcode", rs.getString("postcode"));
                map.put("address", rs.getString("address"));
                map.put("detailaddress", rs.getString("detailaddress"));
                map.put("extraaddress", rs.getString("extraaddress"));
                
                map.put("totalprice", rs.getString("totalprice"));
                map.put("deliverystatus", rs.getString("deliverystatus"));
                
                map.put("productname", "LP 상품"); 
                
                orderList.add(map);
            }
        } finally {
            close();
        }
        return orderList;
    }

    // 13. 리뷰 전체 목록 조회
    @Override
    public List<Map<String, String>> getReviewList(Map<String, String> paraMap) throws SQLException {
        List<Map<String, String>> reviewList = new ArrayList<>();
        try {
            conn = ds.getConnection();
            
            String sql = " SELECT R.reviewno, R.reviewcontent, R.rating, "
                       + "        to_char(R.writedate, 'yyyy-mm-dd') AS writedate, "
                       + "        M.name, "
                       + "        P.productname "
                       + " FROM tbl_review R "
                       + " JOIN tbl_member M ON R.fk_userid = M.userid "
                       + " JOIN tbl_product P ON R.fk_productno = P.productno "
                       + " ORDER BY R.reviewno DESC ";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                Map<String, String> map = new HashMap<>();
                map.put("reviewno", rs.getString("reviewno"));
                map.put("reviewcontent", rs.getString("reviewcontent")); 
                map.put("rating", rs.getString("rating")); 
                map.put("writedate", rs.getString("writedate"));
                map.put("name", rs.getString("name"));       
                map.put("productname", rs.getString("productname")); 
                
                reviewList.add(map);
            }
        } finally {
            close();
        }
        return reviewList;
    }
    
    // 14. 문의 내역 전체 조회
    @Override
    public List<InquiryVO> getInquiryList(Map<String, String> paraMap) throws SQLException {
        List<InquiryVO> inquiryList = new ArrayList<>();
        
        try {
            conn = ds.getConnection();
            
            String sql = " SELECT inquiryno, fk_userid, inquirycontent, "
                       + "        to_char(inquirydate, 'yyyy-mm-dd') AS inquirydate, "
                       + "        inquirystatus, adminreply "
                       + " FROM tbl_inquiry "
                       + " ORDER BY inquiryno DESC ";
            
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                InquiryVO ivo = new InquiryVO();
                ivo.setInquiryno(rs.getInt("inquiryno"));
                ivo.setFk_userid(rs.getString("fk_userid"));
                ivo.setInquirycontent(rs.getString("inquirycontent"));
                ivo.setInquirydate(rs.getString("inquirydate"));
                ivo.setInquirystatus(rs.getString("inquirystatus")); 
                ivo.setAdminreply(rs.getString("adminreply"));
                
                inquiryList.add(ivo);
            }
        } finally {
            close();
        }
        return inquiryList;
    }
    
    // 15. 문의 답변 등록 및 수정 (Update)
    @Override
    public int replyInquiry(String inquiryno, String adminreply) throws SQLException {
        int result = 0;
        try {
            conn = ds.getConnection();
            
            String sql = " UPDATE tbl_inquiry "
                       + " SET adminreply = ?, "
                       + "     inquirystatus = '답변완료', "
                       + "     replydate = sysdate "
                       + " WHERE inquiryno = ? ";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, adminreply);
            pstmt.setString(2, inquiryno);
            
            result = pstmt.executeUpdate();
            
        } finally {
            close();
        }
        return result;
    }

}