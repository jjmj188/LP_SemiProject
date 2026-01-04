package member.model;

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

public class MypageDAO_imple implements MypageDAO {

	
	private DataSource ds; // DataSource ds 는 아파치톰캣이 제공하는 DBCP(DB Connection Pool)이다.
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	// 기본 생성자
	public MypageDAO_imple() {
		
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

 	//마이페이지 문의작성하기
	@Override
	public int insertInquiry(String userid, String inquirycontent) throws SQLException {
		
		int result = 0;

		try {
			conn = ds.getConnection();
			
			String sql = " INSERT INTO tbl_inquiry "
					+ " ( inquiryno, fk_userid, inquirycontent ) "
					+ " VALUES "
					+ " ( seq_inquiryno.nextval, ?, ? ) ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			pstmt.setString(2, inquirycontent);

			result = pstmt.executeUpdate();

		} finally {
			close();
		}

		return result;
	}
}
