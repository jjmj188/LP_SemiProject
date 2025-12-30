package member.domain;

// 주문
public class OrderDTO {
	private int orderno; // 주문번호
	private String userid; // 회원아이디
	private int totalprice; // 주문총액
	private int usepoint; // 사용포인트
	private int totalpoint; // 적립 포인트: 주문총 포인트
	private String orderdate; // 주문일자
	private String postcode; // 우편번호
	private String address; // 주소
	private String detailaddress; // 상세주소
	private String extraaddress; // 주소참고항목
	private String deliverystatus; // 배송상태
	private String ordercomment; // 주문 관련 문의 사항
	private String deliveryrequest; // 배송시 요청사항
	
	
	
	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public int getOrderno() {
		return orderno;
	}
	public void setOrderno(int orderno) {
		this.orderno = orderno;
	}
	public String getUserid() {
		return userid;
	}
	public void setUserid(String userid) {
		this.userid = userid;
	}
	public int getTotalprice() {
		return totalprice;
	}
	public void setTotalprice(int totalprice) {
		this.totalprice = totalprice;
	}
	public int getUsepoint() {
		return usepoint;
	}
	public void setUsepoint(int usepoint) {
		this.usepoint = usepoint;
	}
	public int getTotalpoint() {
		return totalpoint;
	}
	public void setTotalpoint(int totalpoint) {
		this.totalpoint = totalpoint;
	}
	public String getOrderdate() {
		return orderdate;
	}
	public void setOrderdate(String orderdate) {
		this.orderdate = orderdate;
	}
	public String getPostcode() {
		return postcode;
	}
	public void setPostcode(String postcode) {
		this.postcode = postcode;
	}
	public String getAddress() {
		return address;
	}
	public void setAddress(String address) {
		this.address = address;
	}
	public String getDetailaddress() {
		return detailaddress;
	}
	public void setDetailaddress(String detailaddress) {
		this.detailaddress = detailaddress;
	}
	public String getExtraaddress() {
		return extraaddress;
	}
	public void setExtraaddress(String extraaddress) {
		this.extraaddress = extraaddress;
	}
	public String getDeliverystatus() {
		return deliverystatus;
	}
	public void setDeliverystatus(String deliverystatus) {
		this.deliverystatus = deliverystatus;
	}
	public String getOrdercomment() {
		return ordercomment;
	}
	public void setOrdercomment(String ordercomment) {
		this.ordercomment = ordercomment;
	}
	public String getDeliveryrequest() {
		return deliveryrequest;
	}
	public void setDeliveryrequest(String deliveryrequest) {
		this.deliveryrequest = deliveryrequest;
	}
	
	
	
}
