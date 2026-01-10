package order.controller;

import java.io.BufferedReader;
import java.util.List;

import org.json.JSONObject;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import order.domain.CartDTO;
import order.domain.OrderDTO;
import order.model.*;

public class Pay extends AbstractController {

	private OrderDAO odao = new OrderDAO_imple();
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		int n = 0;
		String message ="";
		String loc="";
		
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
		try(BufferedReader br = request.getReader()){
			String line;
			while((line = br.readLine())!=null) {
				sb.append(line);
			}
		}
		
		if(sb.length() == 0) {
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

		// 4) payload 값 받기 (클라에서 보내는 값들)
		String postcode = body.optString("postcode", "").trim();
		String address = body.optString("address", "").trim();
		String detailaddress = body.optString("detailaddress", "").trim();
		String extraaddress = body.optString("extraaddress", "").trim();
		String deliveryrequest = body.optString("deliveryrequest", "").trim();

		int usepoint = body.optInt("usepoint", 0);

		// 아임포트 관련(현재 테이블에 저장은 못 하지만, 검증/로그용으로 받음)
		String imp_uid = body.optString("imp_uid", "");
		String merchant_uid = body.optString("merchant_uid", "");
		int paid_amount = body.optInt("paid_amount", 0);

		

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
			// 결제금액이 없으면 주문 저장 자체를 막는게 맞음
			message = "결제 금액이 올바르지 않습니다.";
			loc = "history.back()";
		}
		else {
			/*
			  6) 주문 저장 데이터 만들기
			     - totalprice: 최종 결제금액(= paid_amount)로 저장하는게 가장 일관됨
			     - totalpoint: 장바구니 상품 기준으로 서버가 계산해야 정상
			     - 주문 상세: 장바구니 목록 기준으로 생성
			*/

			// 6-1) 장바구니에서 주문상세 만들기 (※ 너 프로젝트의 장바구니 조회 메서드에 맞춰 구현돼야 함)
			// odao.insertOrderByCart() 안에서 "장바구니조회 + total 계산 + orderdetail 생성"까지 처리하도록 만들면 편함.
			OrderDTO odto = new OrderDTO();
			odto.setUserid(userid);
			odto.setTotalprice(paid_amount);  // 최종 결제금액 저장
			odto.setUsepoint(usepoint);
			// totalpoint는 DAO에서 장바구니 기반으로 계산해서 세팅/반환해도 됨. 여기서는 0으로 두고 DAO에서 세팅 가능.
			odto.setTotalpoint(0);

			odto.setPostcode(postcode);
			odto.setAddress(address);
			odto.setDetailaddress(detailaddress);
			odto.setExtraaddress(extraaddress);
			odto.setDeliveryrequest(deliveryrequest);

			/*
			  7) DB 저장(트랜잭션)
			     - tbl_order insert
			     - tbl_orderdetail insert(장바구니 기반)
			     - (선택) tbl_member 포인트 갱신: point = point - usepoint + totalpoint
			     - (선택) 장바구니 비우기
			 */
			CartDAO cdao = new CartDAO_imple();
			List<CartDTO> cartList = cdao.selectCartList(userid);
			
			try {
				// 아래 메서드는 너가 구현해야 하는 DAO 메서드야 (밑에 예시 DAO 코드도 같이 줌)
				
				int orderno = odao.insertOrderPay(odto, userid, cartList);

				if (orderno > 0) {
					n = 1;

					// 세션 포인트도 갱신해주는게 UX 좋음 (DAO에서 포인트 업데이트 했다는 전제)
					// DAO에서 계산된 적립포인트를 odto.setTotalpoint(...)로 세팅해주면 여기서 반영 가능
					loginuser.setPoint(loginuser.getPoint() - usepoint + odto.getTotalpoint());

					message = "주문이 완료되었습니다.";
					loc = request.getContextPath() + "/WEB-INF/my_info/my_order.jsp?orderno=" + orderno;

					// 디버깅 필요하면 로그 찍어도 됨
					System.out.println("[PAY] imp_uid=" + imp_uid + ", merchant_uid=" + merchant_uid + ", paid_amount=" + paid_amount);
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

		JSONObject jsonObj = new JSONObject();
		jsonObj.put("n", n);
		jsonObj.put("message", message);
		jsonObj.put("loc", loc);

		request.setAttribute("json", jsonObj.toString());
		super.setRedirect(false);
		super.setViewPage("/WEB-INF/jsonview.jsp");
		
	}

}
