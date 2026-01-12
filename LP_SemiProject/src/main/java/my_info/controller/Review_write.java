package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class Review_write extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		String prdName = request.getParameter("prdName");
		String prdImg  = request.getParameter("prdImg");
		String price   = request.getParameter("price");

		if (prdName == null) prdName = "";
		if (prdImg  == null) prdImg  = "";
		if (price   == null) price   = "0";

		request.setAttribute("prdName", prdName);
		request.setAttribute("prdImg", prdImg);
		request.setAttribute("price", price);

		setRedirect(false);
	    setViewPage("/WEB-INF/my_info/review_write.jsp");
		
	}

}
