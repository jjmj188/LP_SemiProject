package my_info.controller;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class My_inquiry extends AbstractController {

	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		setRedirect(false);
	      setViewPage("/WEB-INF/my_info/my_inquiry.jsp");
		
	}

}
