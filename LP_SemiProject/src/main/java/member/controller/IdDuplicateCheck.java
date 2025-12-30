package member.controller;

import org.json.JSONObject;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;

public class IdDuplicateCheck extends AbstractController{
	private MemberDAO mdao = new MemberDAO_imple();
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

		String method = request.getMethod(); // "GET" 또는 "POST" 
		
		if("POST".equalsIgnoreCase(method)) {
			
			String userid = request.getParameter("userid"); 
			
			boolean isExists = mdao.idDuplicateCheck(userid); 
		//	System.out.println("~~~ 확인용 isExists => " + isExists);
			// ~~~ 확인용 isExists => true
			// ~~~ 확인용 isExists => false
			
			JSONObject jsonObj = new JSONObject(); // {}
			jsonObj.put("isExists", isExists);     // {"isExists":true} 또는 {"isExists":false}
			
			String json = jsonObj.toString(); // 문자열 형태인 "{"isExists":true}" 또는 "{"isExists":false}" 으로 만들어준다.  
		//	System.out.println(">>> 확인용 json => " + json);
			// >>> 확인용 json => {"isExists":true}
			// >>> 확인용 json => {"isExists":false}
			
			request.setAttribute("json", json);
			
			super.setRedirect(false);
			super.setViewPage("/WEB-INF/jsonview.jsp");
			
		}// end of if("POST".equalsIgnoreCase(method))------------------
		
	}

}//end of public class IdDuplicateCheck extends AbstractController{
