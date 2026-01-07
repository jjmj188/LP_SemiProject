package admin.model;

public class InquiryVO {

    private int inquiryno;          // 문의번호
    private String fk_userid;       // 회원아이디
    private String inquirycontent;  // 문의내용
    private String inquirydate;     // 작성일자 (TO_CHAR로 문자열 변환 예정)
    private String inquirystatus;   // 문의상태 ('대기', '완료')
    private String adminreply;      // 관리자답변
    private String replydate;       // 답변일자

    // 기본 생성자
    public InquiryVO() {}

    // Getter & Setter
    public int getInquiryno() { return inquiryno; }
    public void setInquiryno(int inquiryno) { this.inquiryno = inquiryno; }

    public String getFk_userid() { return fk_userid; }
    public void setFk_userid(String fk_userid) { this.fk_userid = fk_userid; }

    public String getInquirycontent() { return inquirycontent; }
    public void setInquirycontent(String inquirycontent) { this.inquirycontent = inquirycontent; }

    public String getInquirydate() { return inquirydate; }
    public void setInquirydate(String inquirydate) { this.inquirydate = inquirydate; }

    public String getInquirystatus() { return inquirystatus; }
    public void setInquirystatus(String inquirystatus) { this.inquirystatus = inquirystatus; }

    public String getAdminreply() { return adminreply; }
    public void setAdminreply(String adminreply) { this.adminreply = adminreply; }

    public String getReplydate() { return replydate; }
    public void setReplydate(String replydate) { this.replydate = replydate; }
}