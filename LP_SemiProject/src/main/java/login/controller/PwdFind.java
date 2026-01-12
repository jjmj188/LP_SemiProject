package login.controller;

import java.util.HashMap;
import java.util.Map;
import java.util.Random;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.model.*;
import net.nurigo.java_sdk.api.Message;
import mail.controller.GoogleMail;

public class PwdFind extends AbstractController {

	private MemberDAO mdao = new MemberDAO_imple();
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
	    
	    String method = request.getMethod(); 
	   
	    if("POST".equalsIgnoreCase(method)) {
	        String userid = request.getParameter("userid");
	        String find_method = request.getParameter("find_method");
	        String email = request.getParameter("email");
	        String mobile = request.getParameter("mobile");
	        
	        Map<String, String> paraMap = new HashMap<>();
	        paraMap.put("userid", userid);
	        paraMap.put("find_method", find_method);
	        paraMap.put("email", email);
	        paraMap.put("mobile", mobile);
	        
	        // 1. 회원 존재 여부 확인
	        boolean isUserExists = mdao.isUserExists(paraMap);
	        boolean sendSuccess = false; 
	        
	        if(isUserExists) {
	        	// System.out.println(">>> [확인용] 현재 접속 Method : " + method);
	            // 2. 인증키 생성 (공통 사용을 위해 미리 선언)
	            Random rnd = new Random();
	            String certification_code = "";
	            
	            // 숫자로만 6자리 생성 (SMS/이메일 공통으로 쓰기 가장 무난함)
	            for(int i=0; i<6; i++) {
	                certification_code += String.valueOf(rnd.nextInt(10));
	            }

	            if("email".equals(find_method)) {    
	                // --- 이메일 발송 로직 ---
	                GoogleMail mail = new GoogleMail();
	                try {
	                    mail.send_certification_code(email, certification_code);
	                    sendSuccess = true;
	                } catch(Exception e) {
	                    e.printStackTrace();
	                }
	            } else {
	            	 //System.out.println(">>> [확인용] 현재 접속 Method : " + method);
	                // --- SMS 발송 로직 (Coolsms) ---
	                String api_key = "NCSIGYCBOJDBFDGX"; // 실제 키 넣으세요
	                String api_secret = "VIIHS01C4X0JJNPYCT00YTMP023D3SIM";
	                Message coolsms = new Message(api_key, api_secret);
	                
	                HashMap<String, String> smsMap = new HashMap<>();
	                smsMap.put("to", mobile);
	                smsMap.put("from", "01042842838"); 
	                smsMap.put("type", "SMS");
	                smsMap.put("text", "[VINYST] 인증번호 [" + certification_code + "] 를 인증 창에 입력하세요.");
	                
	                try {
	                    coolsms.send(smsMap); 
	                    sendSuccess = true;
	                } catch(Exception e) {
	                    e.printStackTrace();
	                }
	            }
	            
	            // 3. 발송 성공 시 세션에 인증코드 저장
	            if(sendSuccess) {
	                HttpSession session = request.getSession();
	                session.setAttribute("certification_code", certification_code);
	            }
	        }
	        
	        // 결과값 전달
	        request.setAttribute("isUserExists", isUserExists);
	        request.setAttribute("sendSuccess", sendSuccess); 
	        request.setAttribute("userid", userid);
	        request.setAttribute("email", email);
	        request.setAttribute("mobile", mobile);
	        request.setAttribute("find_method", find_method);
	    }
	    
	    request.setAttribute("method", method);
	    super.setRedirect(false);
	    super.setViewPage("/WEB-INF/login/pwd_find.jsp");        
	}

}
