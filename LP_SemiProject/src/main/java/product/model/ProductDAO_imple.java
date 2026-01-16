package product.model;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;
import java.util.Map;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import product.domain.ProductDTO;
import product.domain.ReviewDTO;
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
    public int getTotalProductCount(int categoryNo, String searchWord) throws SQLException {
        int totalCount = 0;
        try {
            conn = ds.getConnection();
            String sql = " SELECT COUNT(*) FROM tbl_product WHERE 1=1 ";
            
            // 0보다 클 때만 WHERE절 추가
            if(categoryNo > 0) {
            	sql += " AND fk_categoryno = ? ";
            }
            if(searchWord != null && !searchWord.trim().isEmpty()) {
                sql += " AND lower(productname) LIKE '%' || lower(?) || '%' ";
            }
            
            pstmt = conn.prepareStatement(sql);
            
            int idx = 1;
            if(categoryNo > 0) {
                pstmt.setInt(idx++, categoryNo); 
            }
            if(searchWord != null && !searchWord.trim().isEmpty()) {
                pstmt.setString(idx++, searchWord);
            }
            
            rs = pstmt.executeQuery();
            if(rs.next()) totalCount = rs.getInt(1);
            
        } finally {
            close();
        }
        return totalCount;
    }// end of public int getTotalProductCount() throws SQLException-----------------------

	
	// 페이지 번호에 해당하는 상품 리스트(8개)를 가져오는 메소드
	// 페이지 번호에 해당하는 상품 리스트(8개)를 가져오는 메소드
		@Override
		public List<ProductDTO> selectPagingProduct(int currentShowPageNo, int sizePerPage, int categoryNo, String searchWord, String sortType) throws SQLException {
			List<ProductDTO> productList = new ArrayList<>();
			try {
				conn = ds.getConnection();
				int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
				int endRno = startRno + sizePerPage - 1;

				String orderBy = "P.productno DESC";
				
				if(sortType != null && !sortType.isEmpty()) {
					switch (sortType) {
						case "price_low":  
							orderBy = "P.price ASC";  
							break; // 낮은 가격순
						case "price_high": 
							orderBy = "P.price DESC"; 
							break; // 높은 가격순
						case "latest":     
							orderBy = "P.productno DESC";
							break; // 최신순
						case "rating":     
							// 별점순 정렬 로직 (평균 점수 높은순 -> 최신순)
							orderBy = " NVL((SELECT AVG(rating) "
									+ " FROM tbl_review "
									+ " WHERE fk_productno = P.productno), 0) DESC, P.registerday DESC "; 
							break;
						default:            
							orderBy = "P.productno DESC"; break;
					}
				}
				
				// [수정 1] SQL문에 stock 컬럼 추가 (안쪽 SELECT, 바깥쪽 SELECT 모두)
				String sql = " SELECT productno, productname, price, productimg, stock, avg_rating "
						   + " FROM ( "
						   + "      SELECT row_number() over(order by " + orderBy + ") AS rno "
						   + "            , productno, productname, price, productimg, stock "
						   + "            , NVL((SELECT ROUND(AVG(rating), 1) FROM tbl_review WHERE fk_productno = P.productno), 0) AS avg_rating "
						   + "      FROM tbl_product P "
						   + "      WHERE 1=1 "; 
				
				// 조건: 카테고리
				if(categoryNo > 0) {
					sql += " AND fk_categoryno = ? ";
				}
				
				// 조건: 검색어
				if(searchWord != null && !searchWord.trim().isEmpty()) {
					sql += " AND lower(productname) LIKE '%' || lower(?) || '%' ";
				}
				
				sql += " ) V "
					 + " WHERE V.rno BETWEEN ? AND ? ";
				
				pstmt = conn.prepareStatement(sql);

			  
				int idx = 1;
				if(categoryNo > 0) {
					pstmt.setInt(idx++, categoryNo); 
				}
				if(searchWord != null && !searchWord.trim().isEmpty()) {
					pstmt.setString(idx++, searchWord);
				}
				
				pstmt.setInt(idx++, startRno);
				pstmt.setInt(idx++, endRno);
				
				rs = pstmt.executeQuery();
				
				while(rs.next()) {
					ProductDTO pdto = new ProductDTO();
					pdto.setProductno(rs.getInt("productno"));
					pdto.setProductname(rs.getString("productname"));
					pdto.setPrice(rs.getInt("price"));
					pdto.setProductimg(rs.getString("productimg"));
					
					
					pdto.setStock(rs.getInt("stock"));
					
					pdto.setAvgRating(rs.getDouble("avg_rating")); 
					
					productList.add(pdto);
				}
			} finally {
				close();
			}
			return productList;
		}// end of public List<ProductDTO> selectPagingProduct// end of public List<ProductDTO> selectPagingProduct(int currentShowPageNo, int sizePerPage, int categoryNo, String searchWord, String sortType) throws SQLException {
	
	
	
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
	
	}// end of public ProductDTO selectOneProduct(int productno) throws SQLException---------

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
	}// end of public List<TrackDTO> selectTrackList(int productno) throws SQLException

	
	// NEW 제품 조회(최신순으로 10개)
	@Override
	public List<ProductDTO> selectNewProductList() throws SQLException {
		List<ProductDTO> newProductList = new ArrayList<>();
		
		try {
			conn = ds.getConnection();
			
			// 등록일 내림차순으로 정렬 후 상위 10개 SELECT
			String sql = " SELECT productno, productname, productimg, price "
					   + " FROM ( "
					   + "    SELECT productno, productname, productimg, price "
					   + "    FROM tbl_product "
					   + "    ORDER BY registerday DESC " // 최신순
					   + " ) "
					   + " WHERE ROWNUM <= 10 ";
			
			pstmt = conn.prepareStatement(sql);
			rs = pstmt.executeQuery();
			
			while(rs.next()) {
				ProductDTO pdto = new ProductDTO();
				
				pdto.setProductno(rs.getInt("productno"));
				pdto.setProductname(rs.getString("productname"));
				pdto.setProductimg(rs.getString("productimg"));
				pdto.setPrice(rs.getInt("price"));
				
				newProductList.add(pdto);
			}
			
		}finally {
			close();
		}
		
		return newProductList;
	}// end of public List<ProductDTO> selectNewProductList() throws SQLException--------------
  


    // 로그아웃용 (각 카테고리 1개씩)
    @Override
    public List<ProductDTO> selectRandomRecommendation() throws SQLException {
        List<ProductDTO> list = new ArrayList<>();
        try {
            conn = ds.getConnection();
            // 카테고리 1~5번에서 각각 랜덤 1개씩 뽑아서 합침
            String sql = "";
            for(int i=1; i<=5; i++) {
                sql += " (SELECT productno, productname, price, productimg, fk_categoryno "
                     + "  FROM (SELECT * FROM tbl_product WHERE fk_categoryno = ? ORDER BY DBMS_RANDOM.VALUE) "
                     + "  WHERE ROWNUM = 1) ";
                if(i < 5) sql += " UNION ALL ";
            }
            
            pstmt = conn.prepareStatement(sql);
            for(int i=1; i<=5; i++) {
                pstmt.setInt(i, i); // ? 에 1, 2, 3, 4, 5 바인딩
            }
            
            rs = pstmt.executeQuery();
            while(rs.next()) {
                ProductDTO pdto = new ProductDTO();
                pdto.setProductno(rs.getInt("productno"));
                pdto.setProductname(rs.getString("productname"));
                pdto.setPrice(rs.getInt("price"));
                pdto.setProductimg(rs.getString("productimg"));
                pdto.setCategoryno(rs.getInt("fk_categoryno"));
                list.add(pdto);
            }
        } finally {
            close();
        }
        return list;
    }

    // 로그인용 (특정 카테고리 n개)
    @Override
    public List<ProductDTO> selectProductsByCategory(int categoryNo, int count) throws SQLException {
        List<ProductDTO> list = new ArrayList<>();
        try {
            conn = ds.getConnection();
            String sql = " SELECT productno, productname, price, productimg, fk_categoryno "
                       + " FROM (SELECT * FROM tbl_product "
                       + "		 WHERE fk_categoryno = ? "
                       + "	     ORDER BY DBMS_RANDOM.VALUE) "
                       + " WHERE ROWNUM <= ? ";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, categoryNo);
            pstmt.setInt(2, count);
            
            rs = pstmt.executeQuery();
            while(rs.next()) {
                ProductDTO pdto = new ProductDTO();
                pdto.setProductno(rs.getInt("productno"));
                pdto.setProductname(rs.getString("productname"));
                pdto.setPrice(rs.getInt("price"));
                pdto.setProductimg(rs.getString("productimg"));
                pdto.setCategoryno(rs.getInt("fk_categoryno"));
                list.add(pdto);
            }
        } finally {
            close();
        }
        return list;
    }// end of public List<ProductDTO> selectProductsByCategory(int categoryNo, int count) throws SQLException {-----------

    

    // 특정 제품의 리뷰 총 개수 (페이징 계산용)
    @Override
    public int getTotalReviewCount(int productno) throws SQLException {
        int count = 0;
        try {
            conn = ds.getConnection();
            String sql = " SELECT count(*) "
            		   + " FROM tbl_review "
            		   + " WHERE fk_productno = ? ";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productno);
            
            rs = pstmt.executeQuery();
            if(rs.next()) {
            	count = rs.getInt(1);
            }
        } finally {
            close();
        }
        return count;
    }// end of public int getTotalReviewCount(int productno) throws SQLException 

    // 페이징 처리된 리뷰 목록 (5개씩)
    @Override
    public List<ReviewDTO> selectReviewListPaging(Map<String, String> paraMap) throws SQLException {
        List<ReviewDTO> reviewList = new ArrayList<>();
        try {
            conn = ds.getConnection();
            
            int currentShowPageNo = Integer.parseInt(paraMap.get("currentShowPageNo"));
            int sizePerPage = Integer.parseInt(paraMap.get("sizePerPage"));
            int productno = Integer.parseInt(paraMap.get("productno"));
            
            int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
            int endRno = startRno + sizePerPage - 1;
            
            String sql = " SELECT reviewno, fk_userid, rating, reviewcontent, writedate "
                       + " FROM ( "
                       + "    SELECT row_number() over(order by reviewno desc) as rno, "
                       + "           reviewno, fk_userid, rating, reviewcontent, to_char(writedate, 'yyyy-mm-dd') as writedate "
                       + "    FROM tbl_review "
                       + "    WHERE fk_productno = ? "
                       + " ) V "
                       + " WHERE V.rno BETWEEN ? AND ? ";
            
            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, productno);
            pstmt.setInt(2, startRno);
            pstmt.setInt(3, endRno);
            
            rs = pstmt.executeQuery();
            
            while(rs.next()) {
                ReviewDTO rdto = new ReviewDTO();
                rdto.setReviewno(rs.getInt("reviewno"));
                rdto.setUserid(rs.getString("fk_userid"));
                rdto.setRating(rs.getInt("rating"));
                rdto.setReviewcontent(rs.getString("reviewcontent"));
                rdto.setWritedate(rs.getString("writedate"));
                
                reviewList.add(rdto);
            }
        } finally {
            close();
        }
        return reviewList;
    }// end of public List<ReviewDTO> selectReviewListPaging(Map<String, String> paraMap) throws SQLException {---------------------------
}
