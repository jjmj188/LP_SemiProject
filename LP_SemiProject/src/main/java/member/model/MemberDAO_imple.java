package member.model;

import java.io.UnsupportedEncodingException;
import java.security.GeneralSecurityException;
import java.security.NoSuchAlgorithmException;
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

import member.domain.MemberDTO;

import util.security.AES256;
import util.security.SecretMyKey;
import util.security.Sha256;
import product.domain.ReviewDTO;


public class MemberDAO_imple implements MemberDAO {

	private DataSource ds; // DataSource ds 는 아파치톰캣이 제공하는 DBCP(DB Connection Pool)이다.
	private Connection conn;
	private PreparedStatement pstmt;
	private ResultSet rs;
	
	private AES256 aes;
	
	// 기본 생성자
	public MemberDAO_imple() {
		
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

 	
 	
 
 	//================================================================================================//
	// ID 중복검사 (tbl_member 테이블에서 userid 가 존재하면 true 를 리턴해주고, userid 가 존재하지 않으면 false 를 리턴한다) 
	@Override
	public boolean idDuplicateCheck(String userid) throws SQLException {
		
		boolean isExists = false;
		
		try {
			conn = ds.getConnection();
			
			String sql = " select userid "
					   + " from tbl_member "
					   + " where userid = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, userid);
			
			rs = pstmt.executeQuery();
			
			isExists = rs.next(); // 행이 있으면(중복된 userid) true,
			                      // 행이 없으면(사용가능한 userid) false
			
		} finally {
			close();
		}
		
		return isExists;
	}// end of public boolean idDuplicateCheck(String userid) throws SQLException------

	
	//==================================================================================//
	// 비밀번호 중복검사 (tbl_member 테이블에서 email이 존재하면 true 를 리턴해주고, email이 존재하지 않으면 false 를 리턴한다)
	@Override
	public boolean emailDuplicateCheck(String email) throws SQLException {
	boolean isExists = false;
		
		try {
			conn = ds.getConnection();
			
			String sql = " select email "
					   + " from tbl_member "
					   + " where email = ? ";
			
			pstmt = conn.prepareStatement(sql);
			pstmt.setString(1, aes.encrypt(email));
			
			rs = pstmt.executeQuery();
			
			isExists = rs.next(); // 행이 있으면(중복된 email) true,
			                      // 행이 없으면(사용가능한 email) false
			
		} catch(GeneralSecurityException | UnsupportedEncodingException e) {
			  e.printStackTrace();
		} finally {
			close();
		}
		
		return isExists;		
	}//end of public boolean emailDuplicateCheck(String email) throws SQLException

	//====================================================================================//
			// 회원가입을 해주는 메서드(tbl_member 테이블에 insert)
				@Override
				public int registerMember(MemberDTO member) throws SQLException {
					
					int result = 0;
					
					try {
						  conn = ds.getConnection();
						  
						  String sql = " insert into tbl_member( userseq,userid, pwd, name, email, mobile, gender, birthday, "
						  		     + " postcode ,address ,detailaddress ,extraaddress ) "  
						  		     + " values( seq_userseq.nextval, ?, ?, ?, ?, ?, ?, ? ,? ,? ,? ,? ) "; 
						  
						  pstmt = conn.prepareStatement(sql); 
						  
						  pstmt.setString(1, member.getUserid());
						  pstmt.setString(2, Sha256.encrypt(member.getPwd()) ); // 암호를 SHA256 알고리즘으로 단방향 암호화 시킨다.
						  pstmt.setString(3, member.getName());
						  pstmt.setString(4, aes.encrypt(member.getEmail()) );  // 이메일을 AES256 알고리즘으로 양방향 암호화 시킨다.
						  pstmt.setString(5, aes.encrypt(member.getMobile()) ); // 휴대폰을 AES256 알고리즘으로 양방향 암호화 시킨다.
						  pstmt.setString(6, member.getGender());
						  pstmt.setString(7, member.getBirthday());
						  
						  pstmt.setString(8, member.getPostcode());
						  pstmt.setString(9, member.getAddress());
						  pstmt.setString(10, member.getDetailaddress());
						  pstmt.setString(11, member.getExtraaddress());
						  
						  result = pstmt.executeUpdate();
						  
					} catch(GeneralSecurityException | UnsupportedEncodingException e) {
						  e.printStackTrace();
					} finally {
						close();
					}
					
					return result;
				}// end of public int registerMember(MemberDTO member) throws SQLException-------*/
		

		//=========================================================================
		//취향선택 메서드
		@Override
		public int insertTaste(String userid, String[] arr) throws SQLException {
			
			int n=0;
			
			String sql="insert into tbl_member_preference(fk_userid,fk_categoryno) "
					 + " values (?, ?)";
				  try {
				        conn = ds.getConnection();
				        pstmt = conn.prepareStatement(sql);

				        for(String categoryNo : arr) {
				            pstmt.setString(1, userid);
				            pstmt.setInt(2, Integer.parseInt(categoryNo));
				            n+= pstmt.executeUpdate();
				        }

				    } finally {
				        close();
				 }
		  return n;
		}

		//로그인메서드==================================================================================
	 	@Override
	 	public MemberDTO login(Map<String, String> paraMap) {
	 	    MemberDTO member = null;

	 	    try {
	 	        conn = ds.getConnection();

	 	        // 1. 조회 시점에 마지막 로그인 갭을 계산합니다.
	 	        // NVL을 추가하여 신규 회원이 첫 로그인 시 에러가 나지 않도록 방어했습니다.
	 	        String sql = " SELECT userid, name, lastpwdchangedate, registerday, point , idle, email, mobile, "
	 	        		   + "        postcode, address, detailaddress, extraaddress, "
	 	                   + "        TRUNC(MONTHS_BETWEEN(SYSDATE, lastpwdchangedate)) AS pwdchangegap, "
	 	                   + "        TRUNC(MONTHS_BETWEEN(SYSDATE, "
	 	                   + "              NVL((SELECT MAX(logindate) FROM tbl_loginhistory WHERE fk_userid = userid), registerday) "
	 	                   + "        )) AS last_login_gap "
	 	                   + " FROM tbl_member "
	 	                   + " WHERE status = 1 AND userid = ? AND pwd = ? ";

	 	        pstmt = conn.prepareStatement(sql);
	 	        pstmt.setString(1, paraMap.get("userid"));
	 	        pstmt.setString(2, Sha256.encrypt(paraMap.get("pwd")));
	 	        
	 	        rs = pstmt.executeQuery();
	 	        
	 	        if (rs.next()) {
	 	            member = new MemberDTO();
	 	            member.setUserid(rs.getString("userid"));
	 	            member.setName(rs.getString("name"));
	 	            member.setPoint(rs.getInt("point"));
	 	            member.setIdle(rs.getInt("idle")); // 현재 DB 저장값 (0 또는 1)
	 	            member.setRegisterday(rs.getString("registerday"));
	 	            member.setEmail(aes.decrypt(rs.getString("email")));
	 	            member.setMobile(aes.decrypt(rs.getString("mobile")));
	 	            
	 	            member.setPostcode(rs.getString("postcode"));
		 	        member.setAddress(rs.getString("address"));
		 	        member.setDetailaddress(rs.getString("detailaddress"));
		 	        member.setExtraaddress(rs.getString("extraaddress"));
	 	            // 비밀번호 변경 필요 여부 (3개월)
	 	            member.setRequirePwdChange(rs.getInt("pwdchangegap") >= 3);

	 	            // 마지막 로그인 후 경과 개월 수
	 	            int lastLoginGap = rs.getInt("last_login_gap");
	 	            member.setLastLoginGap(lastLoginGap);

	 	            // --- 실시간 휴면 처리 추가 로직 --- //
	 	            
	 	            // 만약 DB에는 활동중(0)인데, 날짜 계산 결과 12개월 이상 지났다면
	 	            if (member.getIdle() == 0 && lastLoginGap >= 12) {
	 	                
	 	                // 1) 자바 객체 상태를 휴면(1)으로 변경
	 	                member.setIdle(1);
	 	                
	 	                // 2) DB 테이블의 idle 컬럼도 1로 즉시 업데이트
	 	                sql = " UPDATE tbl_member SET idle = 1 WHERE userid = ? ";
	 	                pstmt = conn.prepareStatement(sql);
	 	                pstmt.setString(1, member.getUserid());
	 	                pstmt.executeUpdate();
	 	                
	 	                // 참고: 이 경우 컨트롤러에서는 loginuser.getIdle() == 1 조건을 타서 
	 	                // idle_release.lp 페이지로 가게 됩니다.
	 	            }
	 	         
	 	        }
	 	    } catch (SQLException | GeneralSecurityException | UnsupportedEncodingException e) {
	 	        e.printStackTrace();
	 	    } finally {
	 	        close();
	 	    }
	 	    return member;
	 	}
	 	
	 	//==============================================================================
		// 휴면계정 처리
		@Override
		public void updateIdle(String userid) throws SQLException {

		    try {
		        conn = ds.getConnection();

		        String sql =
		            " UPDATE tbl_member "
		          + " SET idle = 1 "
		          + " WHERE userid = ? "
		          + "   AND idle = 0 "
		          + "   AND ( "
		          + "        SELECT NVL(MAX(logindate), SYSDATE) "
		          + "        FROM tbl_loginhistory "
		          + "        WHERE fk_userid = ? "
		          + "       ) <= ADD_MONTHS(SYSDATE, -12) ";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, userid);
		        pstmt.setString(2, userid);

		        pstmt.executeUpdate();

		    } finally {
		        close();
		    }
		}



	//=============================================================================================//
	// 로그인 기록 insert
		@Override
		public void insertLoginHistory(String userid, String clientip) throws SQLException {
		    
		    try {
		        conn = ds.getConnection();
		        
		        String sql = " insert into tbl_loginhistory "
		                   + " (historyno, fk_userid, logindate, clientip) "
		                   + " values (seq_historyno.nextval, ?, sysdate, ?) ";
		        
		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, userid);
		        pstmt.setString(2, clientip);
		        
		        pstmt.executeUpdate();
		        
		    } finally {
		        close();
		    }
		}



   // 비밀번호 재설정 + 휴면 해제 + 로그인 기록===============================================================
		@Override
		public int changePassword(String userid, String newPwd, String clientip) throws SQLException {

		    int result = 0;

		    try {
		        conn = ds.getConnection();

		        // 1️ 기존 비밀번호와 동일한지 검사
		        String sql = "SELECT pwd FROM tbl_member WHERE userid = ?";
		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, userid);
		        rs = pstmt.executeQuery();

		        if (rs.next()) {
		            String oldPwd = rs.getString("pwd");
		            String newPwdEnc = Sha256.encrypt(newPwd);

		            if (oldPwd.equals(newPwdEnc)) {
		                return -1; //  기존 비밀번호와 동일
		            }
		        }

		        // 2️. 비밀번호 변경 + 휴면 해제
		        sql = "UPDATE tbl_member "
		            + " SET pwd = ?, "
		            + "     lastpwdchangedate = SYSDATE, "
		            + "     idle = 0 "
		            + " WHERE userid = ?";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, Sha256.encrypt(newPwd));
		        pstmt.setString(2, userid);

		        result = pstmt.executeUpdate(); // 1이면 성공

		        // 3️. 로그인 기록 INSERT 
		        if (result == 1) {
		            sql = "INSERT INTO tbl_loginhistory "
		                + " (historyno, fk_userid, logindate, clientip) "
		                + " VALUES (seq_historyno.nextval, ?, SYSDATE, ?)";

		            pstmt = conn.prepareStatement(sql);
		            pstmt.setString(1, userid);
		            pstmt.setString(2, clientip);

		            pstmt.executeUpdate();
		            
		            conn.commit();
		        }

		    } catch (Exception e) {
		        e.printStackTrace();
		    } finally {
		        close();
		    }

		    return result;
		}

		// 아이디 찾기(성명, 이메일을 입력받아서 해당 사용자의 아이디를 알려준다)
		@Override
		public String findUserid(Map<String, String> paraMap) throws SQLException {
			
			String userid = null;
			
			try {
				 conn = ds.getConnection();
						 
				 String sql = " SELECT userid "
				 		    + " FROM tbl_member "
				 		    + " WHERE status = 1 AND name = ? AND email = ? ";
				 
				 pstmt = conn.prepareStatement(sql);
				 pstmt.setString(1, paraMap.get("name"));
				 pstmt.setString(2, aes.encrypt(paraMap.get("email")));
				 
				 rs = pstmt.executeQuery();
				 
				 if(rs.next()) {
					 userid = rs.getString("userid");
				 }
				 
			} catch(GeneralSecurityException | UnsupportedEncodingException e) {
				  e.printStackTrace();
			} finally {
				close();
			}
			
			return userid;
		}// end of public String findUserid(Map<String, String> paraMap) throws SQLException-------


		// 비밀번호 찾기(아이디, 이메일을 입력받아서 해당 사용자가 존재하는지 여부를 알려준다)
				@Override
				public boolean isUserExists(Map<String, String> paraMap) throws SQLException {
					
					boolean isUserExists = false;
					
					try {
						 conn = ds.getConnection();
								 
						 String sql = " SELECT userid "
						 		    + " FROM tbl_member "
						 		    + " WHERE status = 1 AND userid = ? AND (email = ? OR mobile = ?) ";
						 
						 pstmt = conn.prepareStatement(sql);
						 
						 pstmt.setString(1, paraMap.get("userid"));
						 // 1. 이메일 암호화 처리 (이메일이 없으면 null이 들어가도록 처리)
					        String email = paraMap.get("email");
					        pstmt.setString(2, (email != null) ? aes.encrypt(email) : ""); 
					        
					        // 2. 세 번째 파라미터(mobile) 추가 (누락되었던 부분)
					        String mobile = paraMap.get("mobile");
					        pstmt.setString(3, (mobile != null) ? aes.encrypt(mobile) : "");
						 
						 rs = pstmt.executeQuery();
						 
						 isUserExists = rs.next();
						 
					} catch(GeneralSecurityException | UnsupportedEncodingException e) {
						  e.printStackTrace();
					} finally {
						close();
					}		
					
					return isUserExists;
				}// end of public boolean isUserExists(Map<String, String> paraMap) throws SQLException------

		//===========================================================================
		// 비밀번호 찾기 시 현재 비밀번호와 같은지 여부 확인 및 update
				@Override
				public int pwdUpdate(Map<String, String> paraMap) throws SQLException {
				    int result = 0;
				    
				    try {
				        conn = ds.getConnection();
				        
				        // 1️ 먼저 기존 비밀번호를 가져와서 비교합니다.
				        String sql = " select pwd from tbl_member where userid = ? ";
				        
				        pstmt = conn.prepareStatement(sql);
				        pstmt.setString(1, paraMap.get("userid"));
				        rs = pstmt.executeQuery();
				        
				        if(rs.next()) {
				            String current_pwd = rs.getString("pwd");
				            String new_pwd_enc = Sha256.encrypt(paraMap.get("new_pwd"));
				            
				            // 기존 암호와 새 암호가 같다면 업데이트를 하지 않고 -1을 리턴함
				            if(current_pwd.equals(new_pwd_enc)) {
				                return -1; 
				            }
				        }
				        
				        // 2️ 기존 암호와 다를 경우에만 실제로 업데이트를 진행
				        sql = " update tbl_member set pwd = ?, lastpwdchangedate = sysdate " 
				            + " where userid = ? ";
				         
				        pstmt = conn.prepareStatement(sql);
				        pstmt.setString(1, Sha256.encrypt(paraMap.get("new_pwd")));
				        pstmt.setString(2, paraMap.get("userid"));  
				            
				        result = pstmt.executeUpdate(); // 성공하면 1
				         
				    } finally {
				        close();
				    }
				    
				    return result;
				}

		
		

			//회원탈퇴시 비밀번호가 맞는지 확인========================================
			@Override
			public boolean checkPassword(String userid, String pwd) {
			    boolean isCorrect = false;
			    
			    try {
			        conn = ds.getConnection();
			        
			        // 암호화된 비밀번호와 아이디가 일치하는 회원이 있는지 확인
			        String sql = " SELECT count(*) FROM tbl_member "
			                   + " WHERE userid = ? AND pwd = ? AND status = 1 ";
			        
			        pstmt = conn.prepareStatement(sql);
			        pstmt.setString(1, userid);
			        pstmt.setString(2, Sha256.encrypt(pwd)); // 비밀번호 암호화 필수!
			        
			        rs = pstmt.executeQuery();
			        
			        if(rs.next()) {
			            int n = rs.getInt(1);
			            if(n == 1) isCorrect = true;
			        }
			        
			    } catch(Exception e) {
			        e.printStackTrace();
			    } finally {
			        close();
			    }
			    
			    return isCorrect;
			}
		







		//주문내역 / 리뷰 / 결제 / 로그 남아야 FK 걸린 테이블 다 깨짐 실무에서 회원 DELETE 거의 안 함
		//비밀번호가 맞을 경우 회원탈퇴
		
			public int withdrawMember(String userid) {
			    int n = 0;
			    
			    try {
			        conn = ds.getConnection();
			        
			        // status를 0(탈퇴)으로 바꾸고 idle_date(또는 withdraw_date)를 현재 시간으로 기록
			        // 보통 status 1: 활동, 0: 탈퇴(휴면)
			        String sql = "UPDATE tbl_member SET status = 0 WHERE userid = ?";
			        
			        pstmt = conn.prepareStatement(sql);
			        pstmt.setString(1, userid);
			        
			        n = pstmt.executeUpdate();
			        
			    } catch(Exception e) {
			        e.printStackTrace();
			    } finally {
			        close();
			    }
			    
			    return n;
			}
			
		



		//마이페이지 업데이트하기
		@Override
		public int updateMemberInfo(MemberDTO member) throws SQLException {
			 int result = 0;

			    try {
			        conn = ds.getConnection();

			        String sql =" update tbl_member set " +
			          " name = ?, email = ?, mobile = ?, " +
			          " postcode = ?, address = ?, detailaddress = ?, extraaddress = ? " +
			          " where userid = ? ";

			        pstmt = conn.prepareStatement(sql);
			        pstmt.setString(1, member.getName());
			        pstmt.setString(2, aes.encrypt(member.getEmail()));
			        pstmt.setString(3, aes.encrypt(member.getMobile()));
			        pstmt.setString(4, member.getPostcode());
			        pstmt.setString(5, member.getAddress());
			        pstmt.setString(6, member.getDetailaddress());
			        pstmt.setString(7, member.getExtraaddress());
			        pstmt.setString(8, member.getUserid());

			        result = pstmt.executeUpdate(); // 1 이면 성공
			    } catch(GeneralSecurityException | UnsupportedEncodingException e) {
					  e.printStackTrace();
				} finally {
			        close();
			    }

			    return result;

		}
		//내가 선택한 취향 먼저 보여주기 
				@Override
				public List<Integer> getUserPreference(String userid) throws SQLException {

				    List<Integer> prefList = new ArrayList<>();

				    try {
				        conn = ds.getConnection();

				        String sql =
				            " SELECT fk_categoryno " +
				            " FROM tbl_member_preference " +
				            " WHERE fk_userid = ? ";

				        pstmt = conn.prepareStatement(sql);
				        pstmt.setString(1, userid);

				        rs = pstmt.executeQuery();

				        while (rs.next()) {
				            prefList.add(rs.getInt("fk_categoryno"));
				        }

				    } catch (SQLException e) {
				        e.printStackTrace();
				    } finally {
				        close();
				    }

				    return prefList;
				}
				
		
		//취향수정하기
		@Override
		public boolean updateMemberPreference(String userid, String[] categoryArr) throws SQLException {
			boolean result=false;
			
	  try {
				conn=ds.getConnection();
				conn.setAutoCommit(false);
				//delete insert 둘다 해야하는데 하나라도 실패할 경우 하나라도 실패 → ROLLBACK
				
				
				//기존취향 전부 삭제 
			    String sql="DELETE FROM tbl_member_preference WHERE fk_userid = ?";
				
			    pstmt=conn.prepareStatement(sql);
				pstmt.setString(1, userid);
				pstmt.executeUpdate();
					
				 sql = "INSERT INTO tbl_member_preference (fk_userid, fk_categoryno) VALUES (?, ?)";
				
				 pstmt=conn.prepareStatement(sql);
				 
				 
				 for(String categoryno : categoryArr) {
					 pstmt.setString(1, userid);
			            pstmt.setInt(2, Integer.parseInt(categoryno));
			            pstmt.executeUpdate();
			        }
			    
			    conn.commit();
		        result = true;
			
	         } catch(Exception e) {
			        e.printStackTrace();
			  } finally {
			        close();
		 }
		  return result;
	}



		// MemberDAO_imple.java
		@Override
		public MemberDTO getMemberByUserid(String userid) throws SQLException {
		    MemberDTO member = null;

		    try {
		        conn = ds.getConnection();

		        // 포인트(point)를 포함하여 필요한 컬럼들을 모두 조회합니다.
		        String sql = " SELECT userid, name, email, mobile, postcode, address, detailaddress, extraaddress, point, registerday, idle "
		                   + " FROM tbl_member "
		                   + " WHERE userid = ? ";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, userid);

		        rs = pstmt.executeQuery();

		        if (rs.next()) {
		            member = new MemberDTO();
		            member.setUserid(rs.getString("userid"));
		            member.setName(rs.getString("name"));
		            member.setPoint(rs.getInt("point")); // 이 부분이 있어야 포인트가 갱신됩니다!
		            member.setIdle(rs.getInt("idle"));
		            member.setRegisterday(rs.getString("registerday"));
		            
		            // 이메일과 전화번호는 암호화되어 저장되어 있다면 복호화 처리를 해줍니다.
		            member.setEmail(aes.decrypt(rs.getString("email")));
		            member.setMobile(aes.decrypt(rs.getString("mobile")));
		            
		            member.setPostcode(rs.getString("postcode"));
		            member.setAddress(rs.getString("address"));
		            member.setDetailaddress(rs.getString("detailaddress"));
		            member.setExtraaddress(rs.getString("extraaddress"));
		        }
		    } catch (GeneralSecurityException | UnsupportedEncodingException e) {
		        e.printStackTrace();
		    } finally {
		        close(); // 자원 반납
		    }

		    return member;
		}

		//내리뷰보기 
		@Override
		public List<ReviewDTO> selectMyReviewList(String userid) throws SQLException {

		    List<ReviewDTO> reviewList = new ArrayList<>();

		    try {
		        conn = ds.getConnection();

		        // 제품명(productname), 이미지(productimg), 리뷰내용, 별점, 날짜를 조인해서 가져옴
		        String sql = " SELECT R.reviewno, R.fk_productno AS Productno , R.rating, R.reviewcontent, "
		                   + "        TO_CHAR(R.writedate, 'yyyy-mm-dd') AS writedate, "
		                   + "        P.productname, P.productimg "
		                   + " FROM tbl_review R "
		                   + " JOIN tbl_product P ON R.fk_productno = P.productno "
		                   + " WHERE R.fk_userid = ? "
		                   + " ORDER BY R.writedate DESC ";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, userid);

		        rs = pstmt.executeQuery();

		        while (rs.next()) {
		            ReviewDTO rdto = new ReviewDTO();
		            rdto.setReviewno(rs.getInt("reviewno"));
		            rdto.setProductno(rs.getInt("productno"));
		            rdto.setRating(rs.getInt("rating")); // 정수형 별점 (1~5)
		            rdto.setReviewcontent(rs.getString("reviewcontent")); // "제품이 너무 좋아요..."
		            rdto.setWritedate(rs.getString("writedate"));

		         // JOIN으로 가져온 상품 정보 세팅
		            rdto.setProductname(rs.getString("productname")); 
		            rdto.setProductimg(rs.getString("productimg"));

		            reviewList.add(rdto);
		        }

		    } finally {
		        close();
		    }

		    return reviewList;
		}
		// 특정 리뷰 1개 상세 조회 (리뷰번호 기준)
		@Override
		public ReviewDTO selectOneReview(int reviewno) throws SQLException {
		    ReviewDTO rdto = null;
		    try {
		        conn = ds.getConnection();

		        // 리스트 때와 마찬가지로 상품 테이블과 조인해서 상품명, 이미지를 가져옵니다.
		        String sql = " SELECT R.reviewno, R.fk_productno, R.rating, R.reviewcontent, "
		                   + "        TO_CHAR(R.writedate, 'yyyy-mm-dd') AS writedate, "
		                   + "        P.productname, P.productimg "
		                   + " FROM tbl_review R "
		                   + " JOIN tbl_product P ON R.fk_productno = P.productno "
		                   + " WHERE R.reviewno = ? ";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setInt(1, reviewno);

		        rs = pstmt.executeQuery();

		        if (rs.next()) { // 1개만 조회하므로 while 대신 if
		            rdto = new ReviewDTO();
		            rdto.setReviewno(rs.getInt("reviewno"));
		            rdto.setProductno(rs.getInt("fk_productno"));
		            rdto.setRating(rs.getInt("rating"));
		            rdto.setReviewcontent(rs.getString("reviewcontent"));
		            rdto.setWritedate(rs.getString("writedate"));
		            rdto.setProductname(rs.getString("productname")); 
		            rdto.setProductimg(rs.getString("productimg"));
		        }
		    } finally {
		        close();
		    }
		    return rdto;
		}
		
		// 내 리뷰 삭제하기
		@Override
		public int deleteReview(String reviewno) throws SQLException {
		    
		    int n = 0;
		    
		    try {
		        conn = ds.getConnection();
		        
		        // 해당 리뷰 번호(PK)를 가진 행을 삭제합니다.
		        String sql = " delete from tbl_review "
		                   + " where reviewno = ? ";
		        
		        pstmt = conn.prepareStatement(sql);
		        pstmt.setString(1, reviewno);
		        
		        n = pstmt.executeUpdate(); // 성공하면 1, 실패하면 0 반환
		        
		    } finally {
		        close(); // 자원 반납
		    }
		    
		    return n;
		}
		
		
		
}//end







		








		
			
		



		

		
		
















