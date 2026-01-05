package member.domain;

// 1:1 문의
public class InquiryDTO {
	
	private int inquiryno; // 문의번호
	private String userid; // 회원아이디
	private String inquirycontent; // 문의내용
	private String inquirydate; // 문의 작성일
	private String inquirystatus; // 문의상태
	private String adminreply; // 관리자답변
	private String replydate; // 답변일
	
	
	
	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public int getInquiryno() {
		return inquiryno;
	}
	public void setInquiryno(int inquiryno) {
		this.inquiryno = inquiryno;
	}
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public String getInquirycontent() {
		return inquirycontent;
	}
	public void setInquirycontent(String inquirycontent) {
		this.inquirycontent = inquirycontent;
	}
	public String getInquirydate() {
		return inquirydate;
	}
	public void setInquirydate(String inquirydate) {
		this.inquirydate = inquirydate;
	}
	public String getInquirystatus() {
		return inquirystatus;
	}
	public void setInquirystatus(String inquirystatus) {
		this.inquirystatus = inquirystatus;
	}
	public String getAdminreply() {
		return adminreply;
	}
	public void setAdminreply(String adminreply) {
		this.adminreply = adminreply;
	}
	public String getReplydate() {
		return replydate;
	}
	public void setReplydate(String replydate) {
		this.replydate = replydate;
	}
	
	
	
}
