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

import member.domain.InquiryDTO;
import util.security.AES256;
import util.security.SecretMyKey;

public class InquiryDAO_imple implements InquiryDAO {

	
	private DataSource ds; // DataSource ds 는 아파치톰캣이 제공하는 DBCP(DB Connection Pool)이다.
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	// 기본 생성자
	public InquiryDAO_imple() {
		
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

	//마이페이지 자신의 문의내역 조회
	@Override
	public List<InquiryDTO> selectInquiryList(String userid) throws SQLException {
		List<InquiryDTO> list = new ArrayList<>();

	    String sql =
	      " select inquiryno, fk_userid, inquirycontent "
	      + " ,to_char(inquirydate,'yyyy-mm-dd') AS inquirydate "
	      + " ,inquirystatus "
	      + " ,adminreply "
	      + " ,to_char(replydate,'yyyy-mm-dd') AS replydate " 
	      + " from tbl_inquiry " 
	      + " where fk_userid = ? " 
	      + " order by inquiryno desc ";

	    try (Connection conn = ds.getConnection();
	         PreparedStatement pstmt = conn.prepareStatement(sql)) {

	        pstmt.setString(1, userid);
	        
	        

	        try (ResultSet rs = pstmt.executeQuery()) {
	            while (rs.next()) {
	                InquiryDTO dto = new InquiryDTO();
	                dto.setInquiryno(rs.getInt("inquiryno"));
	                dto.setUserid(rs.getString("fk_userid")); 
	                dto.setInquirycontent(rs.getString("inquirycontent"));
	                dto.setInquirydate(rs.getString("inquirydate"));  
	                dto.setInquirystatus(rs.getString("inquirystatus"));
	                dto.setAdminreply(rs.getString("adminreply"));
	                dto.setReplydate(rs.getString("replydate"));
	                list.add(dto);
	            }
	        }
	    }

	    return list;
	}

	// 총 문의 수 / 총 페이지
	@Override
	public int getTotalInquiryCount(String userid) throws SQLException {
		int totalCount = 0;

		  try {
		    conn = ds.getConnection();

		    String sql = " SELECT COUNT(*) "
		               + " FROM tbl_inquiry "
		               + " WHERE fk_userid = ? ";

		    pstmt = conn.prepareStatement(sql);
		    pstmt.setString(1, userid);

		    rs = pstmt.executeQuery();
		    if (rs.next()) {
		      totalCount = rs.getInt(1);
		    }

		  } finally {
		    close();
		  }

		  return totalCount;
	}

	// 목록 조회 (페이징)
	@Override
	public List<InquiryDTO> selectInquiryPaging(String userid, int currentShowPageNo, int sizePerPage) throws SQLException {

	  List<InquiryDTO> list = new java.util.ArrayList<InquiryDTO>();

	  try {
	    conn = ds.getConnection();

	   
	    
	    String sql =
	        " select inquiryno, fk_userid, inquirycontent"
	        	+ " ,to_char(inquirydate,'yyyy-mm-dd') AS inquirydate "
	        + ", inquirystatus, adminreply"
	        + " ,to_char(replydate,'yyyy-mm-dd') AS replydate " 
	        + " from tbl_inquiry "
	        + " where fk_userid = ? "
	        + " order by inquiryno desc " 
	        + " offset (?-1)*? rows " 
	        + " fetch next ? rows only ";

	    pstmt = conn.prepareStatement(sql);
	    pstmt.setString(1, userid);
	    pstmt.setInt(2, currentShowPageNo);
	    pstmt.setInt(3, sizePerPage);
	    pstmt.setInt(4, sizePerPage);

	    rs = pstmt.executeQuery();

	    while (rs.next()) {
	      InquiryDTO dto = new InquiryDTO();
	      dto.setInquiryno(rs.getInt("inquiryno"));
	      dto.setUserid(rs.getString("fk_userid"));
	      dto.setInquirycontent(rs.getString("inquirycontent"));
	      dto.setInquirydate(rs.getString("inquirydate"));
	      dto.setInquirystatus(rs.getString("inquirystatus"));
	      dto.setAdminreply(rs.getString("adminreply"));
	      dto.setReplydate(rs.getString("replydate"));

	      list.add(dto);
	    }

	  } finally {
	    close();
	  }

	  return list;
	}


	


	
	
}
