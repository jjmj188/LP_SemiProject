package member.model;

import java.sql.SQLException;

public interface InquiryDAO {

	//마이페이지 문의작성하기
	int insertInquiry(String userid, String inquirycontent)throws SQLException;
	
}
