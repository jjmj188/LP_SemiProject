package order.model;

import java.io.UnsupportedEncodingException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.List;

import javax.naming.Context;
import javax.naming.InitialContext;
import javax.naming.NamingException;
import javax.sql.DataSource;

import order.domain.CartDTO;
import order.domain.OrderDTO;
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

    /**
     * 결제 성공 후 주문 저장 (tbl_order + tbl_orderdetail)
     * + 회원 포인트 DB 갱신(point = point - usepoint + totalpoint)
     * + 장바구니 선택삭제(선택된 cartno만 삭제)
     */
    @Override
    public int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList, String[] cartnoArr) throws Exception {

        int orderno = 0;

        try {
            if (cartList == null || cartList.size() == 0) return 0;
            if (cartnoArr == null || cartnoArr.length == 0) return 0;

            conn = ds.getConnection();
            conn.setAutoCommit(false);

            // 1) 주문번호 채번
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

            // 2) tbl_order insert
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

            // 3) tbl_orderdetail insert
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

            // 4) ✅ 회원 포인트 DB 갱신
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

            // 5) ✅ 장바구니 선택삭제: 선택한 cartno만 삭제
            // delete from tbl_cart where fk_userid = ? and cartno in (?,?,...)
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
}
