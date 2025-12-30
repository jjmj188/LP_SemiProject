package member.domain;

// 곡 리스트
public class TrackDTO {
	private int trackno; // 곡번호
	private int productno; // 제품번호(앨범번호)
	private int trackorder; // 앨범 내 곡 순서
	private String tracktitle; // 곡 제목
	
	
	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public int getTrackno() {
		return trackno;
	}
	public void setTrackno(int trackno) {
		this.trackno = trackno;
	}
	public int getProductno() {
		return productno;
	}
	public void setProductno(int productno) {
		this.productno = productno;
	}
	public int getTrackorder() {
		return trackorder;
	}
	public void setTrackorder(int trackorder) {
		this.trackorder = trackorder;
	}
	public String getTracktitle() {
		return tracktitle;
	}
	public void setTracktitle(String tracktitle) {
		this.tracktitle = tracktitle;
	}
	
	
}
