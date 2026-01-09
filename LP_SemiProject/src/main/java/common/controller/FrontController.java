package common.controller;

import jakarta.servlet.RequestDispatcher;
import jakarta.servlet.ServletConfig;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig; // [중요] 추가됨
import jakarta.servlet.annotation.WebInitParam;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.FileInputStream;
import java.io.FileNotFoundException;
import java.io.IOException;
import java.lang.reflect.Constructor;
import java.util.Enumeration;
import java.util.HashMap;
import java.util.Map;
import java.util.Properties;


@WebServlet(
        description = "사용자가 웹에서 *.lp 을 했을 경우 이 서블릿이 응답을 해주도록 한다.", 
        urlPatterns = { "*.lp" }, 
        initParams = { 
                @WebInitParam(name = "propertyConfig", value = "C:/git/LP_SemiProject/LP_SemiProject/src/main/webapp/WEB-INF/Command.properties", description = "사용자가 웹에서 *.lp 을 했을 경우 이 서블릿이 응답을 해주도록 한다.")
        })
// [중요] 아래 어노테이션이 있어야 서블릿 3.0 이상(Tomcat 10 포함)에서 파일 업로드(Part API)가 가능합니다.
@MultipartConfig(
    fileSizeThreshold = 1024 * 1024 * 1,  // 1 MB (메모리에 저장되는 크기 제한)
    maxFileSize = 1024 * 1024 * 10,       // 10 MB (개별 파일 최대 크기)
    maxRequestSize = 1024 * 1024 * 15     // 15 MB (전체 요청 최대 크기)
)
public class FrontController extends HttpServlet {
    private static final long serialVersionUID = 1L;

    private Map<String, Object> cmdMap = new HashMap<>();// 객체저장소 Map<key, value>
    
    public void init(ServletConfig config) throws ServletException {
        
        //특정 파일에 있는 내용을 읽어오기 위한 용도로 쓰이는 객체
        FileInputStream fis = null;
        
        String props = config.getInitParameter("propertyConfig");
        
        try {
            fis = new FileInputStream(props);
            
            Properties pr = new Properties();
            
            pr.load(fis); 
            
            Enumeration<Object> en = pr.keys();
            
            while(en.hasMoreElements()) {
                
                String key = (String) en.nextElement();
                String className = pr.getProperty(key);
                
                if(className != null) {
                    className = className.trim();
                    Class<?> cls = Class.forName(className); 
                    Constructor<?> constrt = cls.getDeclaredConstructor();
                    Object obj = constrt.newInstance();
                    cmdMap.put(key, obj);
                }
            }
            
        } catch (FileNotFoundException e) {
            e.printStackTrace();
        } catch (IOException e) {
            e.printStackTrace();
        } catch (ClassNotFoundException e) {
            System.out.println("문자열로 명명되어진 클래스가 존재하지 않습니다");
            e.printStackTrace();
        } catch (Exception e) {
            e.printStackTrace();
        } 
        
    }

    
    protected void doGet(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        
        String uri = request.getRequestURI();
        String key = uri.substring(request.getContextPath().length()); 
        
        AbstractController action = (AbstractController) cmdMap.get(key); 
        
        if(action == null) {
            System.out.println(">>>" + key + " 은 URI 패턴에 매핑된 클래스는 없습니다.<<<");
        }
        else {
            try {
                action.execute(request, response);
                
                boolean bool = action.isRedirect();
                String viewPage = action.getViewPage();
                
                if(!bool) {
                    if(viewPage != null) {
                        RequestDispatcher disptcher = request.getRequestDispatcher(viewPage);
                        disptcher.forward(request, response);
                    }
                }
                else {
                    if(viewPage != null) {
                        response.sendRedirect(viewPage);
                    }
                }
                
            } catch (Exception e) {
                e.printStackTrace();
            }
        }
    }

    protected void doPost(HttpServletRequest request, HttpServletResponse response) throws ServletException, IOException {
        doGet(request, response);
    }

}