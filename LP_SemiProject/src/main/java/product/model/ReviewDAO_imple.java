package product.model;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import order.domain.OrderDetailDTO;
import util.security.AES256;
import util.security.SecretMyKey;

public class ReviewDAO_imple implements ReviewDAO {

	private DataSource ds;
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	public ReviewDAO_imple() {
		
		try {
			Context initContext = new InitialContext();//DB커넥션플
	        Context envContext  = (Context)initContext.lookup("java:/comp/env");
	        ds = (DataSource)envContext.lookup("SemiProject");
	        
	        aes = new AES256(SecretMyKey.KEY);
	        // SecretMyKey.KEY 은 우리가 만든 암호화/복호화 키이다.
	        
    	} catch(NamingException e) {
    		e.printStackTrace();
    	} catch(UnsupportedEncodingException e) {
    		e.printStackTrace();
    	}
		
	}
	
	// 사용한 자원을 반납하는 close() 메소드 생성하기
 	private void close() {
 		try {
 			if(rs    != null) {rs.close();	  rs=null;}
 			if(pstmt != null) {pstmt.close(); pstmt=null;}
 			if(conn  != null) {conn.close();  conn=null;}
 		} catch(SQLException e) {
 			e.printStackTrace();
 		}
 	}// end of private void close()---------------
	
 	
 	// ============================================================================ //
 	
 	//  (로그인유저, 주문번호, 상품번호)로 "내가 산 상품"인지 DB 검증 + 표시 정보 조회
    @Override
    public OrderDetailDTO selectOrderItemForReview(String userid, int orderno, int productno) throws SQLException {

        OrderDetailDTO dto = null;

        try {
            conn = ds.getConnection();

            String sql =
                " select tbl_product.productname "
                + "     , tbl_product.productimg "
                + "     , tbl_orderdetail.unitprice * tbl_orderdetail.qty as totalprice "
                + " from tbl_order "
                + " join tbl_orderdetail "
                + " on tbl_order.orderno = tbl_orderdetail.fk_orderno "
                + " join tbl_product "
                + " on tbl_orderdetail.fk_productno = tbl_product.productno "
                + " where tbl_order.fk_userid = ? "
                + " and tbl_order.orderno = ? "
                + "  and tbl_orderdetail.fk_productno = ? ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            pstmt.setInt(2, orderno);
            pstmt.setInt(3, productno);

            rs = pstmt.executeQuery();

            if (rs.next()) {
                dto = new OrderDetailDTO();
                dto.setProductname(rs.getString("productname"));
                dto.setProductimg(rs.getString("productimg"));
                dto.setUnitprice(rs.getInt("totalprice"));
            }

        } finally {
            close();
        }

        return dto;
    }

    // 이미 리뷰 작성했으면 막기
    @Override
    public boolean existsReview(String userid, int productno, int orderno) throws SQLException {

        boolean exists = false;

        try {
            conn = ds.getConnection();

            String sql =
                " select 1 " +
                "   from tbl_review " +
                "  where fk_userid = ? " +
                "    and fk_productno = ? " +
                "    and fk_orderno = ? ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            pstmt.setInt(2, productno);
            pstmt.setInt(3, orderno);

            rs = pstmt.executeQuery();
            exists = rs.next();

        } finally {
            close();
        }

        return exists;
    }


 	

}
