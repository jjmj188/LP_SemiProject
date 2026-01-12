package product.domain;

// 제품구매후기
public class ReviewDTO {

    private int reviewno;        // 리뷰번호
    private String userid;       // 회원아이디 (fk_userid)
    private int productno;       // 제품번호 (fk_productno)

    private int orderno;         // 주문번호 (fk_orderno)

    private int rating;          // 별점
    private String reviewcontent;// 리뷰내용
    private String writedate;    // 작성날짜

    // ===== join / 표시용 =====
    private String productname;  // 리뷰 목록 표시용
    private String productimg;   // 리뷰 목록 표시용

    // 주문 당시 구매금액 표시용 (단가*수량)
    private int totalprice;      

    // ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //

    public int getReviewno() {
        return reviewno;
    }
    public void setReviewno(int reviewno) {
        this.reviewno = reviewno;
    }

    public String getUserid() {
        return userid;
    }
    public void setUserid(String userid) {
        this.userid = userid;
    }

    public int getProductno() {
        return productno;
    }
    public void setProductno(int productno) {
        this.productno = productno;
    }

    public int getOrderno() {
        return orderno;
    }
    public void setOrderno(int orderno) {
        this.orderno = orderno;
    }

    public int getRating() {
        return rating;
    }
    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getReviewcontent() {
        return reviewcontent;
    }
    public void setReviewcontent(String reviewcontent) {
        this.reviewcontent = reviewcontent;
    }

    public String getWritedate() {
        return writedate;
    }
    public void setWritedate(String writedate) {
        this.writedate = writedate;
    }

    public String getProductname() {
        return productname;
    }
    public void setProductname(String productname) {
        this.productname = productname;
    }

    public String getProductimg() {
        return productimg;
    }
    public void setProductimg(String productimg) {
        this.productimg = productimg;
    }

    public int getTotalprice() {
        return totalprice;
    }
    public void setTotalprice(int totalprice) {
        this.totalprice = totalprice;
    }
}
