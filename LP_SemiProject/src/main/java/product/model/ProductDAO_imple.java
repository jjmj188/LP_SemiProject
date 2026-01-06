package product.model;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
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

public class ProductDAO_imple implements ProductDAO {
	
	private DataSource ds;
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	public ProductDAO_imple() {
		
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
 	
 	
	// 페이징 처리용 전체상품 조회
	@Override
	public int getTotalProductCount() throws SQLException {
		
		int totalCount = 0;
		
		try {
			conn = ds.getConnection();
			String sql = " SELECT COUNT(*) "
					   + " FROM tbl_product ";
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
                totalCount = rs.getInt(1);
            }
			
		}finally {
			close();
		}
		
		return totalCount;
	}// end of public int getTotalProductCount() throws SQLException-----------------------

	
	// 페이지 번호에 해당하는 상품 리스트(8개)를 가져오는 메소드
	@Override
	public List<ProductDTO> selectPagingProduct(int currentShowPageNo, int sizePerPage) throws SQLException {
		
		List<ProductDTO> productList = new ArrayList<>();
		
		try {
            conn = ds.getConnection();
            
            
            int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
            int endRno   = startRno + sizePerPage - 1;
            
            // 내림차순(최신)
            String sql = " SELECT productno, productname, price, productimg "
                       + " FROM ( "
                       + "     SELECT row_number() over(order by productno desc) AS rno "
                       + "          , productno, productname, price, productimg "
                       + "     FROM tbl_product "
                       + " ) V "
                       + " WHERE V.rno BETWEEN ? AND ? ";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, startRno);
            pstmt.setInt(2, endRno);
            
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                ProductDTO pdto = new ProductDTO();
                
                pdto.setProductno(rs.getInt("productno"));
                pdto.setProductname(rs.getString("productname"));
                pdto.setPrice(rs.getInt("price"));
                pdto.setProductimg(rs.getString("productimg"));
                
                productList.add(pdto);
            }
        } finally {
            close();
        }
        return productList;
	}
  

}
