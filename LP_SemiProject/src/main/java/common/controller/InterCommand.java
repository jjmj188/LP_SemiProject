package common.controller;

import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

public interface InterCommand {
 //이 인터페이스를 구현하는 클래스는 무조건 이 메서드를 가져야 한다. 어떤 컨트롤러든 execute() 하나로 실행된다.
	void execute(HttpServletRequest request, HttpServletResponse response) throws Exception;
}
