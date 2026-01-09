package order.model;

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

import order.domain.CartDTO;
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

	//장바구니 조회
	@Override
	public List<CartDTO> selectCartList(String userid) throws SQLException {
		
		conn = ds.getConnection();
		
		 List<CartDTO> list = new ArrayList<>();
		 
		 String sql =
		            " SELECT tbl_cart.cartno, " +
		            "        tbl_cart.fk_productno, " +
		            "        tbl_cart.qty, " +
		            "        tbl_product.productname, " +
		            "        tbl_product.productimg, " +
		            "        tbl_product.price AS price, " +
		            "        (tbl_product.price * tbl_cart.qty) AS total_price, " +
		            "        tbl_product.point AS point, " +
		            "        (tbl_product.point * tbl_cart.qty) AS total_point " +
		            " FROM tbl_cart " +
		            " JOIN tbl_product " +
		            "   ON tbl_cart.fk_productno = tbl_product.productno " +
		            " WHERE tbl_cart.fk_userid = ? AND tbl_product.stock > 0 " +
		            " ORDER BY tbl_cart.cartno DESC ";
		 
		 try  {
			 	pstmt = conn.prepareStatement(sql);
	            pstmt.setString(1, userid);

	            try (ResultSet rs = pstmt.executeQuery()) {
	                while (rs.next()) {
	                    CartDTO cdto = new CartDTO();
	                    cdto.setCartno(rs.getInt("cartno"));
	                    cdto.setProductno(rs.getInt("fk_productno"));
	                    cdto.setQty(rs.getInt("qty"));

	                    cdto.setProductname(rs.getString("productname"));
	                    cdto.setProductimg(rs.getString("productimg"));

	                    cdto.setPrice(rs.getInt("price"));
	                    cdto.setTotalPrice(rs.getInt("total_price"));

	                    cdto.setPoint(rs.getInt("point"));
	                    cdto.setTotalPoint(rs.getInt("total_point"));

	                    list.add(cdto);
	                }
	            }
	        }
		 	finally {
				close();
			}
		 

	        return list;
		
		
	}
	
	
	//장바구니 수정
	@Override
	public int updateCartQty(String loginuserid, int cartno, int qty) throws SQLException {
		 int result = 0;

		    try {
		        conn = ds.getConnection();

		        String sql =
		              " update tbl_cart "
		            + " set qty = ? "
		            + " where cartno = ? "
		            + "   and fk_userid = ? ";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setInt(1, qty);
		        pstmt.setInt(2, cartno);
		        pstmt.setString(3, loginuserid);

		        result = pstmt.executeUpdate();

		    } finally {
		        close();
		    }

		    return (result == 1 ? 1 : 0);
	}

	//장바구니 개별 삭제
	@Override
	public int deleteSelected(String userid, String[] cartnoArr) throws SQLException {
		
		StringBuilder sb = new StringBuilder();
		for(int i =0; i<cartnoArr.length; i++) {
			sb.append("?");
			if(i<cartnoArr.length -1) {
				sb.append(",");
			}
		}
		conn=ds.getConnection();
		
		String sql =" delete from tbl_cart "
				+ " where fk_userid = ? "
				+ " and cartno in ("+sb.toString()+") ";
		
		try {
			pstmt = conn.prepareStatement(sql);
			int idx=1;
			pstmt.setString(idx++, userid);
			
			for(String cartno : cartnoArr) {
				pstmt.setInt(idx++, Integer.parseInt(cartno));
			}
			
			return pstmt.executeUpdate();
			
		} finally {
			close();
		}
		
	}

	//장바구니 전체삭제
	@Override
	public int deleteAll(String userid) throws SQLException {
		
		
		conn=ds.getConnection();
		
		String sql =" delete from tbl_cart "
				+ " where fk_userid = ? ";
		
		try {
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			
			return pstmt.executeUpdate();
			
		} finally {
			close();
		}
	}

	//DB에서 선택 cartno들에 해당하는 장바구니 목록 조회
	@Override
	public List<CartDTO> selectCartListByCartnoArr(String userid, String[] cartnoArr) throws SQLException {

	    List<CartDTO> list = new java.util.ArrayList<>();

	    if (cartnoArr == null || cartnoArr.length == 0) return list;

	    // IN (?, ?, ?, ...) 동적 생성
	    StringBuilder in = new StringBuilder();
	    for (int i = 0; i < cartnoArr.length; i++) {
	        if (i > 0) in.append(",");
	        in.append("?");
	    }

	    String sql =
	        " select tbl_cart.cartno, tbl_cart.fk_userid, tbl_cart.qty, " +
	        "        tbl_product.productno, tbl_product.productname, tbl_product.productimg, " +
	        "        tbl_product.price, tbl_product.point " +
	        " from tbl_cart join tbl_product " +
	        "   on tbl_cart.fk_productno = tbl_product.productno " +
	        " where tbl_cart.fk_userid = ? " +
	        "   and tbl_cart.cartno in (" + in.toString() + ") " +
	        " order by tbl_cart.cartno desc ";

	    try (java.sql.Connection conn = ds.getConnection();
	         java.sql.PreparedStatement pstmt = conn.prepareStatement(sql)) {

	        int idx = 1;
	        pstmt.setString(idx++, userid);

	        for (String cartno : cartnoArr) {
	            pstmt.setInt(idx++, Integer.parseInt(cartno));
	        }

	        try (java.sql.ResultSet rs = pstmt.executeQuery()) {
	            while (rs.next()) {
	                CartDTO dto = new CartDTO();

	                dto.setCartno(rs.getInt("cartno"));
	                dto.setUserid(rs.getString("fk_userid"));
	                dto.setQty(rs.getInt("qty"));

	                dto.setProductno(rs.getInt("productno"));
	                dto.setProductname(rs.getString("productname"));
	                dto.setProductimg(rs.getString("productimg"));

	                int price = rs.getInt("price");
	                int point = rs.getInt("point");
	                int qty = dto.getQty();

	                dto.setPrice(price);
	                dto.setPoint(point);

	                // qty 반영된 합계 값 세팅(너 cart.jsp에서 dto.totalPrice/dto.totalPoint 쓰고 있음)
	                dto.setTotalPrice(price * qty);
	                dto.setTotalPoint(point * qty);

	                list.add(dto);
	            }
	        }
	    }

	    return list;
	}


	
	

}
