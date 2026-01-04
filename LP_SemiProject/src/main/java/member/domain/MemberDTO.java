package member.domain;

import java.sql.Date;

public class MemberDTO {

    // ===== tbl_member 컬럼 =====
	private int userseq;			  //회원번호									
	private String userid;            // 회원아이디 (PK)
    private String pwd;               // 비밀번호 (SHA-256)
    private String name;              // 회원명
    private String email;             // 이메일 (AES-256)
    private String mobile;            // 휴대폰번호 (AES-256)
    private String gender;            // 성별 (1 / 2)
    private String birthday;           // 생년월일 (YYYY-MM-DD)

    private String registerday;          // 가입일자
    private String lastpwdchangedate;    // 마지막 비밀번호 변경일

    private int status;               // 회원상태 (1:사용, 0:탈퇴)
    private int point;                // 포인트
    private int idle;                 // 휴면여부 (0:활동, 1:휴면)
    
    
    private boolean requirePwdChange=false;
	// 마지막으로 암호를 변경한 날짜가 현재시각으로 부터 3개월이 지났으면 true
	// 마지막으로 암호를 변경한 날짜가 현재시각으로 부터 3개월이 지나지 않았으면 false
    		
    private int lastLoginGap; 
    //마지막 로그인 날짜로부터의 갭차이 1년이 지났을 경우 휴면처리 유무확인


    // ===== getter / setter =====

	public int getUserseq() {
		return userseq;
	}
	public void setUserseq(int userseq) {
		this.userseq = userseq;
	}		
	
	
    		
    public String getUserid() {
        return userid;
    }
    public void setUserid(String userid) {
        this.userid = userid;
    }
    
    

    public String getPwd() {
        return pwd;
    }
    public void setPwd(String pwd) {
        this.pwd = pwd;
    }
    
    

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }

    
    
    public String getEmail() {
        return email;
    }
    public void setEmail(String email) {
        this.email = email;
    }

    
    public String getMobile() {
        return mobile;
    }
    public void setMobile(String mobile) {
        this.mobile = mobile;
    }

    
    
    public String getGender() {
        return gender;
    }
    public void setGender(String gender) {
        this.gender = gender;
    }

    
    public String getBirthday() {
        return birthday;
    }
    public void setBirthday(String birthday) {
        this.birthday = birthday;
    }

    
    public String getRegisterday() {
  		return registerday;
  	}
      
    public void setRegisterday(String registerday) {
		this.registerday = registerday;
	}


    public String getLastpwdchangedate() {
		return lastpwdchangedate;
	}
	public void setLastpwdchangedate(String lastpwdchangedate) {
		this.lastpwdchangedate = lastpwdchangedate;
	}
	
	
	public int getStatus() {
        return status;
    }
    public void setStatus(int status) {
        this.status = status;
    }

    
    
    public int getPoint() {
        return point;
    }
    public void setPoint(int point) {
        this.point = point;
    }

    
    
    public int getIdle() {
        return idle;
    }
    public void setIdle(int idle) {
        this.idle = idle;
    }
    
    
    
	public boolean isRequirePwdChange() {
		return requirePwdChange;
		
	}
	
	public void setRequirePwdChange(boolean requirePwdChange) {
		this.requirePwdChange = requirePwdChange;
	}

	
public int getLastLoginGap() {
return lastLoginGap;
}
public void setLastLoginGap(int lastLoginGap) {
this.lastLoginGap = lastLoginGap;
}
	
}
