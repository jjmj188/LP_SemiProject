package order.domain;

import java.util.List;

// 주문
public class OrderDTO {
    private int orderno;              // 주문번호
    private String userid;            // 회원아이디
    private int totalprice;           // 주문총액(결제금액)
    private int usepoint;             // 사용포인트
    private int totalpoint;           // 적립 포인트
    private String orderdate;         // 주문일자
    private String postcode;          // 우편번호
    private String address;           // 주소
    private String detailaddress;     // 상세주소
    private String extraaddress;      // 주소참고항목
    private String deliveryrequest;   // 배송 요청사항

    // 배송정보(tbl_delivery)
    private String senderName;        // sender_name
    private String deliveryCompany;   // delivery_company
    private String deliverystatus;    // deliverystatus
    private String invoiceNo;         // invoice_no
    private String shippedDate;       // shipped_date
    private String deliveredDate;     // delivered_date

    // 주문 요약(카드 상단)
    private int totalQty;             // 주문 전체 수량 합
    private int itemCount;            // 주문 상품 종류 수
    private int moreCount;            // itemCount - 1

    private int repProductno;         // 대표 상품번호
    private String repProductname;    // 대표 상품명
    private String repProductimg;     // 대표 상품 이미지

    // 주문 상세 리스트
    private List<OrderDetailDTO> orderDetailList;

    // ================= getters / setters =================

    public int getOrderno() { return orderno; }
    public void setOrderno(int orderno) { this.orderno = orderno; }

    public String getUserid() { return userid; }
    public void setUserid(String userid) { this.userid = userid; }

    public int getTotalprice() { return totalprice; }
    public void setTotalprice(int totalprice) { this.totalprice = totalprice; }

    public int getUsepoint() { return usepoint; }
    public void setUsepoint(int usepoint) { this.usepoint = usepoint; }

    public int getTotalpoint() { return totalpoint; }
    public void setTotalpoint(int totalpoint) { this.totalpoint = totalpoint; }

    public String getOrderdate() { return orderdate; }
    public void setOrderdate(String orderdate) { this.orderdate = orderdate; }

    public String getPostcode() { return postcode; }
    public void setPostcode(String postcode) { this.postcode = postcode; }

    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }

    public String getDetailaddress() { return detailaddress; }
    public void setDetailaddress(String detailaddress) { this.detailaddress = detailaddress; }

    public String getExtraaddress() { return extraaddress; }
    public void setExtraaddress(String extraaddress) { this.extraaddress = extraaddress; }

    public String getDeliveryrequest() { return deliveryrequest; }
    public void setDeliveryrequest(String deliveryrequest) { this.deliveryrequest = deliveryrequest; }

    public String getSenderName() { return senderName; }
    public void setSenderName(String senderName) { this.senderName = senderName; }

    public String getDeliveryCompany() { return deliveryCompany; }
    public void setDeliveryCompany(String deliveryCompany) { this.deliveryCompany = deliveryCompany; }

    public String getDeliverystatus() { return deliverystatus; }
    public void setDeliverystatus(String deliverystatus) { this.deliverystatus = deliverystatus; }

    public String getInvoiceNo() { return invoiceNo; }
    public void setInvoiceNo(String invoiceNo) { this.invoiceNo = invoiceNo; }

    public String getShippedDate() { return shippedDate; }
    public void setShippedDate(String shippedDate) { this.shippedDate = shippedDate; }

    public String getDeliveredDate() { return deliveredDate; }
    public void setDeliveredDate(String deliveredDate) { this.deliveredDate = deliveredDate; }

    public int getTotalQty() { return totalQty; }
    public void setTotalQty(int totalQty) { this.totalQty = totalQty; }

    public int getItemCount() { return itemCount; }

    // ✅ 핵심 수정: itemCount 세팅 시 moreCount도 같이 계산
    public void setItemCount(int itemCount) {
        this.itemCount = itemCount;
        this.moreCount = (itemCount > 1) ? (itemCount - 1) : 0;
    }

    public int getMoreCount() { return moreCount; }
    public void setMoreCount(int moreCount) { this.moreCount = moreCount; }

    public int getRepProductno() { return repProductno; }
    public void setRepProductno(int repProductno) { this.repProductno = repProductno; }

    public String getRepProductname() { return repProductname; }
    public void setRepProductname(String repProductname) { this.repProductname = repProductname; }

    public String getRepProductimg() { return repProductimg; }
    public void setRepProductimg(String repProductimg) { this.repProductimg = repProductimg; }

    public List<OrderDetailDTO> getOrderDetailList() { return orderDetailList; }
    public void setOrderDetailList(List<OrderDetailDTO> orderDetailList) { this.orderDetailList = orderDetailList; }
}
