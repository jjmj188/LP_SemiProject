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
}
