package member.domain;

// 로그인 기록
public class LoginhistoryDTO {
	private int historyno;
	private String userid; // 회원아이디
	private String logindate; // 로그인되어진 접속날짜및시간
	private String clientip; // 접속한 클라이언트 IP 주소
	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public int getHistoryno() {
		return historyno;
	}
	public void setHistoryno(int historyno) {
		this.historyno = historyno;
	}
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public String getLogindate() {
		return logindate;
	}
	public void setLogindate(String logindate) {
		this.logindate = logindate;
	}
	public String getClientip() {
		return clientip;
	}
	public void setClientip(String clientip) {
		this.clientip = clientip;
	}
	
	
	
}
