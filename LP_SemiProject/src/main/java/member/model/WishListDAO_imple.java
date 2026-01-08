package member.model;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import product.domain.ProductDTO;
import util.security.AES256;
import util.security.SecretMyKey;

public class WishListDAO_imple implements WishListDAO {
	private DataSource ds;
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	public WishListDAO_imple() {
		
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

 	
 	//=====================================================================//
 	
 	
 	// 찜 추가/삭제 (1=찜추가, 0=찜삭제)
	@Override
	public int toggleWishList(String userid, int productno) throws SQLException {
		int result = 0;
		try {
			conn = ds.getConnection();
			
			String sql = " SELECT count(*) "
					   + " FROM tbl_wishlist "
					   + " WHERE fk_userid = ? AND fk_productno = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			pstmt.setInt(2, productno);
			rs = pstmt.executeQuery();
			
			boolean isExist = false;
			
			if(rs.next()) {
				if(rs.getInt(1) > 0) {
					isExist = true;
				}
			}
			
			if(isExist) {// 해당 제품이 찜 되어있으면 
				sql = " DELETE FROM tbl_wishlist "
					+ " WHERE fk_userid = ? AND fk_productno = ? ";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, userid);
				pstmt.setInt(2, productno);
				pstmt.executeUpdate();
				result = 0; // 찜 삭제
			}
			else {// 해당 제품이 찜 안되있으면
				sql = " INSERT INTO tbl_wishlist(fk_userid, fk_productno) VALUES(?, ?)";
				pstmt = conn.prepareStatement(sql);
				pstmt.setString(1, userid);
				pstmt.setInt(2, productno);
				pstmt.executeUpdate();
				result = 1; // 찜 추가
			}
			
		}finally {
			close();
		}
		
		
		return result;
	}// end of public int toggleWishList(String userid, int productno) throws SQLException------------------------

	
	
	
	// 찜 여부 확인 (1:찜함, 0:안함)
	@Override
	public int checkWishStatus(String userid, int productno) throws SQLException {
		int n = 0;
		try {
			conn = ds.getConnection();
			
			String sql = " SELECT count(*) "
					   + " FROM tbl_wishlist "
					   + " WHERE fk_userid = ? AND fk_productno = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			pstmt.setInt(2, productno);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				n = rs.getInt(1);
			}
			
		}finally {
			close();
		}	
			
			
		return n;
	}// end of public int checkWishStatus(String userid, int productno) throws SQLException-----------------------

	
	
	
	// 내 찜 목록 조회 (마이페이지용)
	@Override
	public List<ProductDTO> selectWishList(String userid) throws SQLException {
		List<ProductDTO> wishList = new ArrayList<>();
		try {
			conn = ds.getConnection();
			
			String sql = " SELECT P.productno, P.productname, P.productimg "
					   + " FROM tbl_product P "
					   + " JOIN tbl_wishlist W ON P.productno = W.fk_productno "
					   + " WHERE W.fk_userid = ? "
					   + " ORDER BY P.productname ASC ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				ProductDTO pdto = new ProductDTO();
				pdto.setProductno(rs.getInt("productno"));
                pdto.setProductname(rs.getString("productname"));
                pdto.setProductimg(rs.getString("productimg"));
                
                wishList.add(pdto);
			}
			
		}finally {
			close();
		}
		
		return wishList;
	}// end of public List<ProductDTO> selectWishList(String userid) throws SQLException {---------------
 	
 	
 	
 	
 	
 	
 	
 	
}
