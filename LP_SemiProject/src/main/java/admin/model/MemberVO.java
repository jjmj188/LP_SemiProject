package admin.model;

public class MemberVO {

    // === 필드 (tbl_member 테이블 컬럼과 1:1 대응) ===
    
    private int userseq;             // 회원 번호 (시퀀스로 들어가는 고유번호)
    private String userid;           // 회원 아이디
    private String pwd;              // 비밀번호 (SHA-256 암호화 대상)
    private String name;             // 회원명
    private String email;            // 이메일 (AES-256 암호화 대상)
    private String mobile;           // 휴대폰번호 (AES-256 암호화 대상)
    private String gender;           // 성별 ("1":남, "2":여)
    private String birthday;         // 생년월일 (VARCHAR2 타입)
    
    private String postcode;         // 우편번호
    private String address;          // 주소
    private String detailaddress;    // 상세주소
    private String extraaddress;     // 참고항목
    
    private int point;               // 포인트
    
    // DB에는 DATE 타입이지만, VO에서는 화면 출력을 위해 String으로 받는 것이 편함 (TO_CHAR 사용 권장)
    private String registerday;      // 가입일자 
    private String lastpwdchangedate;// 마지막 비밀번호 변경일
    
    private int status;              // 회원 탈퇴 유무 (1: 사용중, 0: 탈퇴)
    private int idle;                // 휴면 계정 유무 (0: 휴면, 1: 활성)

    
    // === 기본 생성자 ===
    public MemberVO() { }


    // === Getter & Setter (이클립스 자동생성 기능 사용 권장) ===
    
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

    public int getPoint() {
        return point;
    }
    public void setPoint(int point) {
        this.point = point;
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

    public int getIdle() {
        return idle;
    }
    public void setIdle(int idle) {
        this.idle = idle;
    }
    
}