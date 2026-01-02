package member.model;

import java.sql.SQLException;
import java.util.Map;

import member.domain.MemberDTO;

public interface MemberDAO {

	
	// ID 중복검사 (tbl_member 테이블에서 userid 가 존재하면 true 를 리턴해주고, userid 가 존재하지 않으면 false 를 리턴한다)  
   boolean idDuplicateCheck(String userid) throws SQLException;

   // EMAIL 중복검사 (tbl_member 테이블에서 email이 존재하면 true 를 리턴해주고, email이 존재하지 않으면 false 를 리턴한다)
   boolean emailDuplicateCheck(String email) throws SQLException;
   
   //회원가입 메서드
   int registerMember(MemberDTO member) throws SQLException;
   
   //취향선택 메서드
   int insertTaste(String userid, String[] arr)throws SQLException;
   
 
  
   

	
	
	
	
	
}







