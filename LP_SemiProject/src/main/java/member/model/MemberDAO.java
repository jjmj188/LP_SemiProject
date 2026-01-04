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

   //로그인메서드
   MemberDTO login(Map<String, String> paraMap)throws SQLException;
   
   //회원가입 후 로그인 기록남기기
   void insertLoginHistory(String userid, String clientip)throws SQLException;
   
   //비밀번호 변경하기 =>휴면상태/비밀번호 변경3개월 이상/비밀번호 재설정 
   int changePassword(String userid, String newPwd, String clientip) throws SQLException;
   
   // 아이디 찾기(성명, 이메일을 입력받아서 해당 사용자의 아이디를 알려준다)  
	String findUserid(Map<String, String> paraMap) throws SQLException;
	
	// 비밀번호 찾기 눌렀을 겨우 
	int pwdUpdate(Map<String, String> paraMap)throws SQLException;
	
	// 비밀번호 찾기(아이디, 이메일을 입력받아서 해당 사용자가 존재하는지 여부를 알려준다)
		boolean isUserExists(Map<String, String> paraMap) throws SQLException;
 
	//1년 넘었을 경우 휴면처리
	   void updateIdle(String userid)throws SQLException;
   

	
	
	
	
	
}







