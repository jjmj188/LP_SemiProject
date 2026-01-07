package admin.model;

public class ProductVO {

    private int productno;          // 제품번호
    private int fk_categoryno;      // 카테고리번호
    private String productname;     // 제품명
    private String productimg;      // 제품이미지 파일명
    private int stock;              // 재고량
    private int price;              // 가격
    private String productdesc;     // 제품설명
    private String youtubeurl;      // 유튜브 링크
    private String registerday;     // 등록일
    private int point;              // 포인트
    
    // Select용 추가 필드 (tbl_category 조인)
    private String categoryname;    // 카테고리명 (POP, ROCK 등)

    public ProductVO() {}

    // Getter & Setter
    public int getProductno() { return productno; }
    public void setProductno(int productno) { this.productno = productno; }

    public int getFk_categoryno() { return fk_categoryno; }
    public void setFk_categoryno(int fk_categoryno) { this.fk_categoryno = fk_categoryno; }

    public String getProductname() { return productname; }
    public void setProductname(String productname) { this.productname = productname; }

    public String getProductimg() { return productimg; }
    public void setProductimg(String productimg) { this.productimg = productimg; }

    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }

    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }

    public String getProductdesc() { return productdesc; }
    public void setProductdesc(String productdesc) { this.productdesc = productdesc; }

    public String getYoutubeurl() { return youtubeurl; }
    public void setYoutubeurl(String youtubeurl) { this.youtubeurl = youtubeurl; }

    public String getRegisterday() { return registerday; }
    public void setRegisterday(String registerday) { this.registerday = registerday; }

    public int getPoint() { return point; }
    public void setPoint(int point) { this.point = point; }

    public String getCategoryname() { return categoryname; }
    public void setCategoryname(String categoryname) { this.categoryname = categoryname; }
}