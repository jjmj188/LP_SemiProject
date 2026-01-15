package order.controller;

import java.io.BufferedReader;
import java.util.ArrayList;
import java.util.List;

import org.json.JSONArray;
import org.json.JSONObject;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import mail.controller.GoogleMail;
import member.domain.MemberDTO;
import order.domain.CartDTO;
import order.domain.OrderDTO;
import order.model.CartDAO;
import order.model.CartDAO_imple;
import order.model.OrderDAO;
import order.model.OrderDAO_imple;
import product.domain.ProductDTO;
import product.model.ProductDAO;
import product.model.ProductDAO_imple;

public class Pay extends AbstractController {

    private OrderDAO odao = new OrderDAO_imple();
    private ProductDAO pdao = new ProductDAO_imple();

    // ============================
    //  이미지 경로 정규화 유틸 (추가)
    // ============================
    private String normalizeProductImgToWebPath(String raw) {

        if (raw == null) return "";
        String img = raw.trim();
        if (img.isEmpty()) return "";

        // 1) 절대 URL이면 그대로 사용
        String lower = img.toLowerCase();
        if (lower.startsWith("http://") || lower.startsWith("https://")) {
            return img;
        }

        // 2) 쿼리스트링/해시 제거 (혹시 있을 경우)
        int q = img.indexOf("?");
        if (q >= 0) img = img.substring(0, q);
        int h = img.indexOf("#");
        if (h >= 0) img = img.substring(0, h);

        // 3) 경로가 섞여 있어도 마지막 파일명만 추출
        img = img.replace("\\", "/");
        int lastSlash = img.lastIndexOf("/");
        String fileName = (lastSlash >= 0) ? img.substring(lastSlash + 1) : img;
        fileName = fileName.trim();

        if (fileName.isEmpty()) return "";

        // 4) 표준 웹 경로로 통일
        return "/images/productimg/" + fileName;
    }
    // ============================

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        int n = 0;
        String message = "";
        String loc = "";

        String method = request.getMethod();
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");

        if (loginuser == null) {
            message = "로그인 후 이용 가능합니다.";
            loc = request.getContextPath() + "/login/login.lp";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", n);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        if (!"POST".equalsIgnoreCase(method)) {
            message = "비정상적인 접근입니다.";
            loc = "history.back()";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", 0);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        String userid = loginuser.getUserid();

        StringBuilder sb = new StringBuilder();
        try (BufferedReader br = request.getReader()) {
            String line;
            while ((line = br.readLine()) != null) {
                sb.append(line);
            }
        }

        if (sb.length() == 0) {
            message = "요청 데이터가 비어있습니다.";
            loc = "history.back()";

            JSONObject jsonObj = new JSONObject();
            jsonObj.put("n", n);
            jsonObj.put("message", message);
            jsonObj.put("loc", loc);

            request.setAttribute("json", jsonObj.toString());
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/jsonview.jsp");
            return;
        }

        JSONObject body = new JSONObject(sb.toString());

        // payload 값 받기
        String postcode = body.optString("postcode", "").trim();
        String address = body.optString("address", "").trim();
        String detailaddress = body.optString("detailaddress", "").trim();
        String extraaddress = body.optString("extraaddress", "").trim();
        String deliveryrequest = body.optString("deliveryrequest", "").trim();

        int usepoint = body.optInt("usepoint", 0);

        String imp_uid = body.optString("imp_uid", "");
        String merchant_uid = body.optString("merchant_uid", "");
        int paid_amount = body.optInt("paid_amount", 0);

        boolean isDirectBuy = body.optBoolean("isDirectBuy", false);

        if (postcode.isEmpty() || address.isEmpty() || detailaddress.isEmpty()) {
            message = "배송지 정보가 누락되었습니다.";
            loc = "history.back()";
        }
        else if (usepoint < 0) {
            message = "포인트 값이 올바르지 않습니다.";
            loc = "history.back()";
        }
        else if (usepoint > loginuser.getPoint()) {
            message = "보유 포인트보다 많이 사용할 수 없습니다.";
            loc = "history.back()";
        }
        else if (paid_amount <= 0) {
            message = "결제 금액이 올바르지 않습니다.";
            loc = "history.back()";
        }
        else {

            CartDAO cdao = new CartDAO_imple();

            List<CartDTO> cartList = null;
            String[] cartnoArr = null;

            // 장바구니 구매
            if (!isDirectBuy) {

                JSONArray cartnoJsonArr = body.optJSONArray("cartnoList");
                if (cartnoJsonArr == null || cartnoJsonArr.length() == 0) {
                    message = "주문할 상품이 없습니다.";
                    loc = request.getContextPath() + "/order/cart.lp";
                }
                else {
                    cartnoArr = new String[cartnoJsonArr.length()];
                    for (int i = 0; i < cartnoJsonArr.length(); i++) {
                        cartnoArr[i] = String.valueOf(cartnoJsonArr.getInt(i));
                    }

                    cartList = cdao.selectCartListByCartnoArr(userid, cartnoArr);

                    if (cartList == null || cartList.isEmpty()) {
                        message = "선택한 상품 정보를 찾을 수 없습니다.";
                        loc = request.getContextPath() + "/order/cart.lp";
                    }
                }
            }

            // 바로구매
            else {
                int productno = body.optInt("productno", 0);
                int qty = body.optInt("qty", 0);

                if (productno <= 0 || qty <= 0) {
                    message = "바로구매 상품 정보가 올바르지 않습니다.";
                    loc = "history.back()";
                }
                else {
                    ProductDTO pDto = pdao.selectOneProduct(productno);

                    if (pDto == null) {
                        message = "상품 정보를 찾을 수 없습니다.";
                        loc = "history.back()";
                    }
                    else if (qty > pDto.getStock()) {
                        message = "재고가 부족합니다. 현재 재고: " + pDto.getStock();
                        loc = "history.back()";
                    }
                    else {
                        CartDTO dto = new CartDTO();
                        dto.setUserid(userid);

                        dto.setProductno(pDto.getProductno());
                        dto.setProductname(pDto.getProductname());
                        dto.setProductimg(pDto.getProductimg());
                        dto.setPrice(pDto.getPrice());
                        dto.setPoint(pDto.getPoint());
                        dto.setQty(qty);

                        dto.setTotalPrice(pDto.getPrice() * qty);
                        dto.setTotalPoint(pDto.getPoint() * qty);

                        cartList = new ArrayList<>();
                        cartList.add(dto);

                        cartnoArr = new String[0];
                    }
                }
            }

            // cartList가 정상일 때만 주문 저장
            if (message.isEmpty()) {

                int sumTotalPoint = 0;
                for (CartDTO cdto : cartList) {
                    sumTotalPoint += cdto.getTotalPoint();
                }

                OrderDTO odto = new OrderDTO();
                odto.setUserid(userid);
                odto.setTotalprice(paid_amount);
                odto.setUsepoint(usepoint);
                odto.setTotalpoint(sumTotalPoint);

                odto.setPostcode(postcode);
                odto.setAddress(address);
                odto.setDetailaddress(detailaddress);
                odto.setExtraaddress(extraaddress);
                odto.setDeliveryrequest(deliveryrequest);

                try {
                    int orderno = odao.insertOrderPay(odto, userid, cartList, cartnoArr);

                    if (orderno > 0) {
                        n = 1;

                        // 세션 포인트 갱신
                        loginuser.setPoint(loginuser.getPoint() - usepoint + odto.getTotalpoint());

                        // ============================
                        //  주문완료 이메일 전송
                        // ============================
                        try {
                        	GoogleMail mail = new GoogleMail();

                        	String baseUrl =
                        	    request.getScheme() + "://" +
                        	    request.getServerName() + ":" +
                        	    request.getServerPort() +
                        	    request.getContextPath();

                        
                        	String logoUrl = baseUrl + "/images/logo.png";

                        	StringBuilder mailSb = new StringBuilder();

                        	mailSb.append("<div style=\"max-width:760px; margin:24px auto; border:1px solid #e9ecef; border-radius:14px; background:#ffffff; box-shadow:0 8px 24px rgba(0,0,0,0.06); overflow:hidden;\">");

                        	// ===== 상단 헤더 =====
                        	mailSb.append("<div style=\"padding:22px 22px 14px 22px; border-bottom:1px solid #eef1f4;\">")
                        	      .append("<div style=\"display:flex; align-items:center; gap:10px; margin-bottom:10px;\">")
                        	      .append("<img src=\"").append(logoUrl).append("\" alt=\"VINYST 로고\" width=\"70\">")
                        	      .append("</div>")

                        	      .append("<h2 style=\"margin:0; font-size:28px; letter-spacing:-0.6px; line-height:1.25; color:#111827;\">")
                        	      .append("주문 완료 안내")
                        	      .append("</h2>")

                        	      .append("<p style=\"margin:10px 0 0 0; font-size:16px; line-height:1.5; color:#111827;\">")
                        	      .append("<span style=\"color:#03C75A; font-weight:800;\">주문이 정상적으로 접수</span>되었습니다.")
                        	      .append("</p>")

                        	      .append("<p style=\"margin:6px 0 0 0; font-size:14px; color:#6b7280;\">")
                        	      .append("주문하신 상품 정보를 아래에서 확인하실 수 있습니다.")
                        	      .append("</p>")
                        	      .append("</div>");

                        	// ===== 본문: 주문 상품 정보 =====
                        	mailSb.append("<div style=\"padding:18px 22px 22px 22px;\">")
                        	      .append("<div style=\"font-size:16px; font-weight:800; color:#111827; margin:0 0 12px 0;\">")
                        	      .append("주문 상품 정보")
                        	      .append("</div>")
                        	      .append("<div style=\"height:2px; background:#111827; opacity:0.15; margin:0 0 14px 0;\"></div>");

                        	// 상품이 여러 개일 수 있으니 카드(테이블) 여러 개 생성
                        	for (CartDTO cdto : cartList) {

                        	    // ✅ 이미지 정규화 적용: /images/productimg/파일명 또는 절대 URL
                        	    String imgWebPath = normalizeProductImgToWebPath(cdto.getProductimg());

                        	    // 메일에는 절대 URL만 써야 함
                        	    String imgSrc = "";
                        	    if (imgWebPath != null && imgWebPath.trim().length() > 0) {
                        	        String lower = imgWebPath.toLowerCase();
                        	        imgSrc = (lower.startsWith("http://") || lower.startsWith("https://"))
                        	                 ? imgWebPath
                        	                 : (baseUrl + imgWebPath);
                        	    }

                        	    

                        	    mailSb.append("<table border=\"1\" style=\"width:100%; border-collapse:separate; border-spacing:0; border:1px solid #e9ecef; border-radius:12px; overflow:hidden; margin-bottom:14px;\">")
                        	          .append("<tbody>");

                        	    // 상품명
                        	    mailSb.append("<tr>")
                        	          .append("<td style=\"width:32%; padding:14px 14px; background:#f8fafc; color:#6b7280; font-size:14px; font-weight:700; border-right:1px solid #eef1f4; border-bottom:1px solid #eef1f4;\">")
                        	          .append("상품명")
                        	          .append("</td>")
                        	          .append("<td style=\"padding:14px 14px; color:#111827; font-size:15px; font-weight:700; border-bottom:1px solid #eef1f4;\">")
                        	          .append(escapeHtml(cdto.getProductname()))
                        	          .append("</td>")
                        	          .append("</tr>");

                        	  

                        	    // 상품 이미지
                        	    mailSb.append("<tr>")
                        	          .append("<td style=\"width:32%; padding:14px 14px; background:#f8fafc; color:#6b7280; font-size:14px; font-weight:700; border-right:1px solid #eef1f4; border-bottom:1px solid #eef1f4;\">")
                        	          .append("상품 이미지")
                        	          .append("</td>")
                        	          .append("<td style=\"padding:14px 14px; border-bottom:1px solid #eef1f4;\">")
                        	          .append("<div style=\"display:flex; align-items:center; gap:14px;\">")
                        	          .append("<div style=\"width:120px; height:120px; border-radius:12px; background:#f3f4f6; border:1px solid #e5e7eb; display:flex; align-items:center; justify-content:center; overflow:hidden;\">");

                        	    if (imgSrc != null && imgSrc.trim().length() > 0) {
                        	        mailSb.append("<img src=\"")
                        	              .append(imgSrc)
                        	              .append("\" alt=\"상품 이미지\" style=\"width:100%; height:100%; object-fit:cover; display:block;\">");
                        	    } else {
                        	        // 이미지 없으면 빈 박스 유지(또는 기본 이미지 넣어도 됨)
                        	        mailSb.append("<div style=\"font-size:12px; color:#9aa0a6;\">No Image</div>");
                        	    }

                        	    mailSb.append("</div>")
                        	          .append("</div>")
                        	          .append("</td>")
                        	          .append("</tr>");

                        	    // 수량
                        	    mailSb.append("<tr>")
                        	          .append("<td style=\"width:32%; padding:14px 14px; background:#f8fafc; color:#6b7280; font-size:14px; font-weight:700; border-right:1px solid #eef1f4;\">")
                        	          .append("수량")
                        	          .append("</td>")
                        	          .append("<td style=\"padding:14px 14px; color:#111827; font-size:15px; font-weight:800;\">")
                        	          .append(cdto.getQty())
                        	          .append("개</td>")
                        	          .append("</tr>");
                        	    
                        	    

                        	    mailSb.append("</tbody></table>");
                        	}
                        	//총 주문가격
                        	mailSb.append("<br>")
                        		  .append("<span style=\"font-weight: bold;\"> 총 주문가격: ₩")
                        		  .append(String.format("%,d", odto.getTotalprice()))
                        		  .append("</span>");
                        	
                        	// 하단 안내 + 배송지
                        	mailSb.append("<div style=\"margin-top:10px; font-size:14px; color:#111827; line-height:1.6;\">")
                        	      .append("<div><b>배송지</b>: ")
                        	      .append(escapeHtml(postcode)).append(" ")
                        	      .append(escapeHtml(address)).append(" ")
                        	      .append(escapeHtml(detailaddress))
                        	      .append("</div>");

                        	if (extraaddress != null && extraaddress.trim().length() > 0) {
                        	    mailSb.append("<div><b>참고</b>: ").append(escapeHtml(extraaddress)).append("</div>");
                        	}

                        	if (deliveryrequest != null && deliveryrequest.trim().length() > 0) {
                        	    mailSb.append("<div><b>배송요청</b>: ").append(escapeHtml(deliveryrequest)).append("</div>");
                        	}

                        	mailSb.append("</div>");

                        	mailSb.append("<p style=\"margin:14px 0 0 0; font-size:13px; color:#6b7280; line-height:1.5;\">")
                        	      .append("본 메일은 발신 전용입니다. 문의가 필요하시면 고객센터 또는 문의하기를 이용해 주세요.")
                        	      .append("</p>");

                        	mailSb.append("</div>"); // padding wrapper 닫기
                        	mailSb.append("</div>"); // outer card 닫기

                        	String emailContents = mailSb.toString();

                        	// 받는사람: 로그인 유저
                        	mail.sendmail_OrderFinish(loginuser.getEmail(), loginuser.getName(), emailContents);

                        }
                        catch (Exception mailEx) {
                            mailEx.printStackTrace();
                        }
                        // ============================

                        message = "주문이 완료되었습니다.";
                        loc = request.getContextPath() + "/my_info/my_order.lp";
                    }
                    else {
                        message = "주문 저장에 실패했습니다.";
                        loc = "history.back()";
                    }
                }
                catch (Exception e) {
                    e.printStackTrace();
                    message = "주문 처리 중 오류가 발생했습니다.";
                    loc = "history.back()";
                }
            }
        }

        JSONObject jsonObj = new JSONObject();
        jsonObj.put("n", n);
        jsonObj.put("message", message);
        jsonObj.put("loc", loc);

        request.setAttribute("json", jsonObj.toString());
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/jsonview.jsp");
    }
    
    private String escapeHtml(String s) {
        if (s == null) return "";
        return s.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }

}
