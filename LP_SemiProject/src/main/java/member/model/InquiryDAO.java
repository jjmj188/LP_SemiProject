package member.model;

import java.sql.SQLException;
import java.util.List;

import member.domain.InquiryDTO;

public interface InquiryDAO {

	//마이페이지 문의작성하기
	int insertInquiry(String userid, String inquirycontent)throws SQLException;

	//마이페이지 자신의 문의내역 조회
	List<InquiryDTO> selectInquiryList(String userid)throws SQLException;

	// 총 문의 수 / 총 페이지
	int getTotalInquiryCount(String userid)throws SQLException;

	// 목록 조회 (페이징)
	List<InquiryDTO> selectInquiryPaging(String userid, int int1, int sizePerPage)throws SQLException;
	
	
	
}
