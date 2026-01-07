package order.domain;

// 장바구니
public class CartDTO {
	private int cartno; // 장바구니 번호
	private String userid; // 회원아이디
	private int productno; // 제품번호
	private int qty; // 장바구니에 담은 제품 수량
	
	private int price;// 상품단가 
	private int totalPrice;//수량 * 상품가격
	
	private int point;     // 상품 1개당 포인트
    private int totalPoint;    // unitPoint*qty
    
    private String productname;
    private String productimg;

   

	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public int getPrice() {
		return price;
	}
	public void setPrice(int price) {
		this.price = price;
	}
	public int getTotalPrice() {
		return totalPrice;
	}
	public void setTotalPrice(int totalPrice) {
		this.totalPrice = totalPrice;
	}
	public int getPoint() {
		return point;
	}
	public void setPoint(int point) {
		this.point = point;
	}
	public int getTotalPoint() {
		return totalPoint;
	}
	public void setTotalPoint(int totalPoint) {
		this.totalPoint = totalPoint;
	}
	public int getCartno() {
		return cartno;
	}
	public void setCartno(int cartno) {
		this.cartno = cartno;
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
	public int getQty() {
		return qty;
	}
	public void setQty(int qty) {
		this.qty = qty;
	}
	
	 public String getProductname() { return productname; }
	 public void setProductname(String productname) { this.productname = productname; }

    public String getProductimg() { return productimg; }
    public void setProductimg(String productimg) { this.productimg = productimg; }

	
}
