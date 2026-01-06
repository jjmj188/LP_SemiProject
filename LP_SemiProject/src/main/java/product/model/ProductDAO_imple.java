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
import product.domain.TrackDTO;
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
	
	// 제품 상세 보기(1개 조회)
	@Override
	public ProductDTO selectOneProduct(int productno) throws SQLException {
		
		ProductDTO pdto = null;
		
		try {
			conn = ds.getConnection();
			
			String sql = " SELECT P.productno, P.fk_categoryno, P.productname, "
					   + " 		  P.productimg, P.price, P.productdesc, P.youtubeurl, "
					   + " 		  P.point, P.stock, "
					   + " 	      to_char(P.registerday, 'yyyy-mm-dd') AS registerday, "
					   + "        C.categoryname "
					   + " FROM tbl_product P "
					   + " JOIN tbl_category C ON P.fk_categoryno = C.categoryno "
					   + " WHERE P.productno = ? ";
		
			pstmt = conn.prepareStatement(sql);
			pstmt.setInt(1, productno);
			
			rs = pstmt.executeQuery();
			
			if(rs.next()) {
				pdto = new ProductDTO();
				
				pdto.setProductno(rs.getInt("productno"));
				pdto.setCategoryno(rs.getInt("fk_categoryno"));
				pdto.setProductname(rs.getString("productname"));
				pdto.setProductimg(rs.getString("productimg"));
				pdto.setPrice(rs.getInt("price"));
				pdto.setProductdesc(rs.getString("productdesc"));
				pdto.setYoutubeurl(rs.getString("youtubeurl"));
				pdto.setPoint(rs.getInt("point"));
				pdto.setStock(rs.getInt("stock"));
				pdto.setRegisterday(rs.getString("registerday"));
				
				// JOIN으로 가져온 카테고리명 (ProductDTO에 필드 추가 필요!)
				pdto.setCategoryname(rs.getString("categoryname"));
			}
		
		}finally {
			close();
		}
		
		return pdto;
	
	}

	@Override
	public List<TrackDTO> selectTrackList(int productno) throws SQLException {
		
		List<TrackDTO> trackList = new ArrayList<>();
		
		try {
			conn = ds.getConnection();
			
			String sql = " SELECT trackno, fk_productno, track_order, track_title "
					   + " FROM tbl_track "
					   + " WHERE fk_productno = ? "
					   + " ORDER BY track_order ASC ";
			
			pstmt = conn.prepareStatement(sql);
			
			pstmt.setInt(1, productno);
			
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				TrackDTO tdto = new TrackDTO();
				
				tdto.setProductno(rs.getInt("fk_productno"));
				tdto.setTrackno(rs.getInt("trackno"));
				tdto.setTrackorder(rs.getInt("track_order"));
				tdto.setTracktitle(rs.getString("track_title"));
				
				trackList.add(tdto);
			}
			
		}finally {
			close();
		}
		
		
		return trackList;
	}
  

}
