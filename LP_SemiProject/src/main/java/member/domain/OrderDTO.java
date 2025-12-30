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
	
}
