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
     * 결제 성공 후 주문 저장 (tbl_order + tbl_orderdetail) + 장바구니 전체삭제
     * @return 성공 시 orderno, 실패 시 0
     */
    @Override
    public int insertOrderPay(OrderDTO odto, String userid, List<CartDTO> cartList) throws Exception {

        int orderno = 0;

        try {
            if (cartList == null || cartList.size() == 0) {
                return 0;
            }

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
            rs.close();
            pstmt.close();

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
            pstmt.close();

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
                    pstmt.close();
                    conn.rollback();
                    return 0;
                }
            }
            pstmt.close();

            // 4) ✅ 장바구니 전체삭제 (같은 conn, 같은 트랜잭션)
            // ⚠️ 테이블명/컬럼명은 네 DB에 맞게 수정!
            sql = " delete from tbl_cart where fk_userid = ? ";
            pstmt = conn.prepareStatement(sql);
            pstmt.setString(1, userid);
            pstmt.executeUpdate();
            pstmt.close();

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
