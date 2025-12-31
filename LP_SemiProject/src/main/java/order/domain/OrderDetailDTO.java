package order.domain;

// 주문상세
public class OrderDetailDTO {
	private int orderdetailno; // 주문상세 일련번호
	private int orderno; // 주문번호
	private int productno; // 제품번호
	private int qty; // 주문량
	private int unitprice; // 주문단가
	
	
	
	// ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ //
	
	public int getOrderdetailno() {
		return orderdetailno;
	}
	public void setOrderdetailno(int orderdetailno) {
		this.orderdetailno = orderdetailno;
	}
	public int getOrderno() {
		return orderno;
	}
	public void setOrderno(int orderno) {
		this.orderno = orderno;
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
	public int getUnitprice() {
		return unitprice;
	}
	public void setUnitprice(int unitprice) {
		this.unitprice = unitprice;
	}
	
	
}
