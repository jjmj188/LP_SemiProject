package order.model;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import util.security.AES256;
import util.security.SecretMyKey;

public class CartDAO_imple implements CartDAO {

	private DataSource ds;
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	public CartDAO_imple() {
		
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

 	// DB 처리 (있으면 update, 없으면 insert)
	@Override
	public int addCart(String loginuserid, int productno, int qty) throws SQLException {
		
		int result =0;
		
		try {
			 conn = ds.getConnection();
			
			//이미 담긴 상품이 있는지 확인
			String sql=" select cartno, qty "
					+ " from tbl_cart "
					+ " where fk_userid = ? and fk_productno= ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, loginuserid);
			pstmt.setInt(2, productno);
			
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
			//DB에 있다면 수량 누적
			int cartno = rs.getInt("cartno");
			
			rs.close();
			pstmt.close();
			
			sql = " update tbl_cart "
					+ " set qty = qty + ? "
					+ " where cartno = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, qty);
			pstmt.setInt(2, cartno);
			
			result = pstmt.executeUpdate();
			
			
			}
			else {
				//없으면 그냥 추가
				rs.close();
				pstmt.close();
				
				sql =" insert into tbl_cart(cartno, fk_userid, fk_productno, qty) " +
	                    " values(seq_cartno.nextval, ?, ?, ?) ";
				
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, loginuserid);
				pstmt.setInt(2, productno);
				pstmt.setInt(3, qty);
				
				result = pstmt.executeUpdate();
				
			}
			
		} finally {
			close();
		}
		
		return (result == 1? 1:0);
	}
	

}
