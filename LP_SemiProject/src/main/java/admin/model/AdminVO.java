package admin.model;

public class AdminVO {

    // === 필드 (tbl_admin 테이블 컬럼과 1:1 대응) ===
    private String adminid;   // 관리자 아이디
    private String adminpwd;  // 관리자 비밀번호 (암호화)

    // === 생성자 ===
    public AdminVO() { }

    public AdminVO(String adminid, String adminpwd) {
        this.adminid = adminid;
        this.adminpwd = adminpwd;
    }

    // === Getter & Setter ===
    public String getAdminid() {
        return adminid;
    }
    public void setAdminid(String adminid) {
        this.adminid = adminid;
    }

    public String getAdminpwd() {
        return adminpwd;
    }
    public void setAdminpwd(String adminpwd) {
        this.adminpwd = adminpwd;
    }
}