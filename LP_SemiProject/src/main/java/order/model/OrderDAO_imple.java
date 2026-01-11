package order.model;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import order.domain.CartDTO;
import order.domain.OrderDTO;
import order.domain.OrderDetailDTO;
import util.security.AES256;
import util.security.SecretMyKey;

public class OrderDAO_imple implements OrderDAO {

    private DataSource ds;
    private Connection conn;
    private PreparedStatement pstmt;
    private ResultSet rs;

    private AES256 aes;

    public OrderDAO_imple() {
        try {
            Context initContext = new InitialContext();
            Context envContext = (Context) initContext.lookup("java:/comp/env");
            ds = (DataSource) envContext.lookup("SemiProject");

            aes = new AES256(SecretMyKey.KEY);

        } catch (NamingException e) {
            e.printStackTrace();
        } catch (UnsupportedEncodingException e) {
            e.printStackTrace();
        }
    }

    private void close() {
        try {
            if (rs != null) { rs.close(); rs = null; }
            if (pstmt != null) { pstmt.close(); pstmt = null; }
            if (conn != null) { conn.close(); conn = null; }
        } catch (SQLException e) {
            e.printStackTrace();
        }
    }

    
    @Override
    public int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList, String[] cartnoArr) throws Exception {

        int orderno = 0;

        try {
            if (cartList == null || cartList.size() == 0) return 0;
            if (cartnoArr == null || cartnoArr.length == 0) return 0;

            conn = ds.getConnection();
            conn.setAutoCommit(false);

            // 주문번호 채번
            String sql = " select seq_orderno.nextval AS orderno from dual ";
            pstmt = conn.prepareStatement(sql);
            rs = pstmt.executeQuery();

            if (rs.next()) {
                orderno = rs.getInt("orderno");
            } else {
                conn.rollback();
                return 0;
            }
            rs.close(); rs = null;
            pstmt.close(); pstmt = null;

            sql = " insert into tbl_order( "
                + " orderno, fk_userid, totalprice, usepoint, totalpoint, "
                + " postcode, address, detailaddress, extraaddress, deliveryrequest "
                + " ) values( "
                + " ?, ?, ?, ?, ?, ?, ?, ?, ?, ? "
                + " ) ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, orderno);
            pstmt.setString(2, userid);
            pstmt.setInt(3, odto.getTotalprice());
            pstmt.setInt(4, odto.getUsepoint());
            pstmt.setInt(5, odto.getTotalpoint());
            pstmt.setString(6, odto.getPostcode());
            pstmt.setString(7, odto.getAddress());
            pstmt.setString(8, odto.getDetailaddress());
            pstmt.setString(9, odto.getExtraaddress());
            pstmt.setString(10, odto.getDeliveryrequest());

            int n1 = pstmt.executeUpdate();
            pstmt.close(); pstmt = null;

            if (n1 != 1) {
                conn.rollback();
                return 0;
            }

            sql = " insert into tbl_orderdetail( "
                + " orderdetailno, fk_orderno, fk_productno, qty, unitprice "
                + " ) values( "
                + " seq_orderdetailno.nextval, ?, ?, ?, ? "
                + " ) ";

            pstmt = conn.prepareStatement(sql);

            for (CartDTO cdto : cartList) {
                int productno = cdto.getProductno();
                int qty = cdto.getQty();
                int unitprice = cdto.getPrice();

                pstmt.setInt(1, orderno);
                pstmt.setInt(2, productno);
                pstmt.setInt(3, qty);
                pstmt.setInt(4, unitprice);

                int n2 = pstmt.executeUpdate();
                if (n2 != 1) {
                    pstmt.close(); pstmt = null;
                    conn.rollback();
                    return 0;
                }
            }
            pstmt.close(); pstmt = null;

            // 회원 포인트 DB 갱신
            // point = point - usepoint + totalpoint
            sql = " update tbl_member "
                + " set point = point - ? + ? "
                + " where userid = ? ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, odto.getUsepoint());
            pstmt.setInt(2, odto.getTotalpoint());
            pstmt.setString(3, userid);

            int n3 = pstmt.executeUpdate();
            pstmt.close(); pstmt = null;

            if (n3 != 1) {
                conn.rollback();
                return 0;
            }

            // 장바구니 선택삭제: 선택한 cartno만 삭제
            
            StringBuilder in = new StringBuilder();
            for (int i = 0; i < cartnoArr.length; i++) {
                if (i > 0) in.append(",");
                in.append("?");
            }

            sql = " delete from tbl_cart "
                + " where fk_userid = ? "
                + "   and cartno in (" + in.toString() + ") ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            for (int i = 0; i < cartnoArr.length; i++) {
                pstmt.setInt(2 + i, Integer.parseInt(cartnoArr[i]));
            }

            pstmt.executeUpdate();
            pstmt.close(); pstmt = null;

            conn.commit();
            return orderno;

        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException e2) {}
            }
            throw e;

        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); } catch (SQLException e) {}
            }
            close();
        }
    }
    
  //주문목록(대표상품/총수량/배송정보 포함)
    @Override
    public List<OrderDTO> selectMyOrderList(String userid) throws Exception {

        List<OrderDTO> list = new ArrayList<>();

        try {
            conn = ds.getConnection();

            String sql =
                " select o.orderno, to_char(o.orderdate,'yyyy.mm.dd') as orderdate, "
              + "        o.totalprice, o.totalpoint, o.usepoint, "
              + "        nvl(d.deliverystatus,'배송준비중') as deliverystatus, "
              + "        d.delivery_company as deliveryCompany, "
              + "        d.invoice_no as invoiceNo, "
              + "        s.totalQty, s.itemCount, "
              + "        r.fk_productno as repProductno, p.productname as repProductname, p.productimg as repProductimg "
              + " from tbl_order o "
              + " left join tbl_delivery d "
              + "   on d.fk_orderno = o.orderno "
              + " join ( "
              + "   select fk_orderno, sum(qty) as totalQty, count(*) as itemCount "
              + "   from tbl_orderdetail "
              + "   group by fk_orderno "
              + " ) s "
              + "   on s.fk_orderno = o.orderno "
              + " join ( "
              + "   select od.fk_orderno, od.fk_productno "
              + "   from tbl_orderdetail od "
              + "   where od.orderdetailno = ( "
              + "     select min(od2.orderdetailno) "
              + "     from tbl_orderdetail od2 "
              + "     where od2.fk_orderno = od.fk_orderno "
              + "   ) "
              + " ) r "
              + "   on r.fk_orderno = o.orderno "
              + " join tbl_product p "
              + "   on p.productno = r.fk_productno "
              + " where o.fk_userid = ? "
              + " order by o.orderno desc ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                OrderDTO dto = new OrderDTO();

                dto.setOrderno(rs.getInt("orderno"));
                dto.setUserid(userid);
                dto.setOrderdate(rs.getString("orderdate"));

                dto.setTotalprice(rs.getInt("totalprice"));
                dto.setTotalpoint(rs.getInt("totalpoint"));
                dto.setUsepoint(rs.getInt("usepoint"));

                dto.setDeliverystatus(rs.getString("deliverystatus"));
                dto.setDeliveryCompany(rs.getString("deliveryCompany"));
                dto.setInvoiceNo(rs.getString("invoiceNo"));

                dto.setTotalQty(rs.getInt("totalQty"));
                dto.setItemCount(rs.getInt("itemCount")); // moreCount 자동 계산됨

                dto.setRepProductno(rs.getInt("repProductno"));
                dto.setRepProductname(rs.getString("repProductname"));
                dto.setRepProductimg(rs.getString("repProductimg"));

                list.add(dto);
            }

        } finally {
            close();
        }

        return list;
    }
    
  //주문별 상세 목록 붙이기
    @Override
    public List<OrderDetailDTO> selectMyOrderDetailList(int orderno, String userid) throws Exception {

        List<OrderDetailDTO> list = new ArrayList<>();

        try {
            conn = ds.getConnection();

            String sql =
                " select od.orderdetailno, od.fk_orderno as orderno, od.fk_productno as productno, "
              + "        od.qty, od.unitprice, (od.qty * od.unitprice) as lineprice, "
              + "        p.productname, p.productimg "
              + " from tbl_orderdetail od "
              + " join tbl_order o "
              + "   on o.orderno = od.fk_orderno "
              + " join tbl_product p "
              + "   on p.productno = od.fk_productno "
              + " where od.fk_orderno = ? "
              + "   and o.fk_userid = ? "
              + " order by od.orderdetailno asc ";

            pstmt = conn.prepareStatement(sql);
            pstmt.setInt(1, orderno);
            pstmt.setString(2, userid);
            rs = pstmt.executeQuery();

            while (rs.next()) {
                OrderDetailDTO dto = new OrderDetailDTO();

                dto.setOrderdetailno(rs.getInt("orderdetailno"));
                dto.setOrderno(rs.getInt("orderno"));
                dto.setProductno(rs.getInt("productno"));
                dto.setQty(rs.getInt("qty"));
                dto.setUnitprice(rs.getInt("unitprice"));
                dto.setLineprice(rs.getInt("lineprice"));

                dto.setProductname(rs.getString("productname"));
                dto.setProductimg(rs.getString("productimg"));

                list.add(dto);
            }

        } finally {
            close();
        }

        return list;
    }

    //주문주소 + 배송정보(송장) 조회
	@Override
	public OrderDTO selectTrackingInfo(int orderno, String userid) throws Exception {
		
		 OrderDTO dto = null;

		    try {
		        conn = ds.getConnection();

		        String sql =
		            " select o.orderno, "
		          + "        o.postcode, o.address, o.detailaddress, o.extraaddress, "
		          + "        o.deliveryrequest, "
		          + "        nvl(d.sender_name,'VINYST') as senderName, "
		          + "        nvl(d.delivery_company,'CJ대한통운') as deliveryCompany, "
		          + "        nvl(d.deliverystatus,'배송준비중') as deliverystatus, "
		          + "        d.invoice_no as invoiceNo, "
		          + "        to_char(d.shipped_date,'yyyy.mm.dd') as shippedDate, "
		          + "        to_char(d.delivered_date,'yyyy.mm.dd') as deliveredDate "
		          + " from tbl_order o "
		          + " left join tbl_delivery d "
		          + "   on d.fk_orderno = o.orderno "
		          + " where o.orderno = ? "
		          + "   and o.fk_userid = ? ";

		        pstmt = conn.prepareStatement(sql);
		        pstmt.setInt(1, orderno);
		        pstmt.setString(2, userid);

		        rs = pstmt.executeQuery();

		        if (rs.next()) {
		            dto = new OrderDTO();
		            dto.setOrderno(rs.getInt("orderno"));
		            dto.setUserid(userid);

		            dto.setPostcode(rs.getString("postcode"));
		            dto.setAddress(rs.getString("address"));
		            dto.setDetailaddress(rs.getString("detailaddress"));
		            dto.setExtraaddress(rs.getString("extraaddress"));
		            dto.setDeliveryrequest(rs.getString("deliveryrequest"));

		            dto.setSenderName(rs.getString("senderName"));
		            dto.setDeliveryCompany(rs.getString("deliveryCompany"));
		            dto.setDeliverystatus(rs.getString("deliverystatus"));
		            dto.setInvoiceNo(rs.getString("invoiceNo"));
		            dto.setShippedDate(rs.getString("shippedDate"));
		            dto.setDeliveredDate(rs.getString("deliveredDate"));
		        }

		    } finally {
		        close();
		    }

		    return dto;
		
	}

	
}
