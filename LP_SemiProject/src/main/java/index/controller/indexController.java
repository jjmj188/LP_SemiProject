package index.controller;

import java.net.Authenticator.RequestorType;
import java.sql.SQLException;
import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public class indexController extends AbstractController {
	
	
	@Override
	public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
		
		  setRedirect(false);
	       setViewPage("/WEB-INF/index.jsp");
	      

		
		}
	
	}


