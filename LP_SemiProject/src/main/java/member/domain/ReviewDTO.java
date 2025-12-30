package member.domain;

// 제품구매후기
public class ReviewDTO {
	private int reviewno; // 리뷰번호
	private String userid; // 회원아이디
	private int productno; // 제품번호
	private int rating; // 별점
	private String reviewcontent; // 리뷰내용
	private String writedate; // 작성날짜
}
