package member.domain;

// 회원 취향
public class MemberpreferenceDTO {
	private String userid; // 회원아이디
	private int categoryno; // 카테고리 번호
	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public int getCategoryno() {
		return categoryno;
	}
	public void setCategoryno(int categoryno) {
		this.categoryno = categoryno;
	}
	
	
	
}
