package admin.controller;

import common.controller.AbstractController;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part; // 표준 파일 업로드 라이브러리

import java.io.File;
import java.util.UUID;

import admin.model.AdminDAO;
import admin.model.ProductVO;

public class AdminProductRegisterController extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        if("POST".equalsIgnoreCase(request.getMethod())) {
            
            // 1. 저장 경로 설정
            ServletContext svlCtx = request.getSession().getServletContext();
            String uploadFileDir = svlCtx.getRealPath("/images/productimg");
            
            // 폴더가 없으면 생성
            File dir = new File(uploadFileDir);
            if(!dir.exists()) { dir.mkdirs(); }
            
            // 2. 파라미터 받기 (MultipartRequest 대신 request.getParameter 사용 가능해짐)
            // 단, 서블릿 설정이 필요하므로 아래 Part 방식으로 받는 것이 안전합니다.
            
            String fk_categoryno = request.getParameter("fk_categoryno");
            String productname = request.getParameter("productname");
            String price = request.getParameter("price");
            String stock = request.getParameter("stock");
            String point = request.getParameter("point");
            String youtubeurl = request.getParameter("youtubeurl");
            String productdesc = request.getParameter("productdesc");
            
            // 3. 파일 업로드 처리 (Part API 사용)
            String productimg = null;
            Part filePart = request.getPart("productimg"); // jsp의 input name
            
            if(filePart != null && filePart.getSize() > 0) {
                // 파일명 중복 방지를 위한 UUID 사용
                String originName = filePart.getSubmittedFileName();
                String ext = originName.substring(originName.lastIndexOf("."));
                String saveName = UUID.randomUUID().toString() + ext;
                
                // 파일 저장
                filePart.write(uploadFileDir + File.separator + saveName);
                productimg = saveName;
            }

            // 4. 트랙 리스트 받기
            String[] trackTitles = request.getParameterValues("track_title");

            // 5. VO 저장 및 DAO 호출
            ProductVO pvo = new ProductVO();
            pvo.setFk_categoryno(Integer.parseInt(fk_categoryno));
            pvo.setProductname(productname);
            pvo.setPrice(Integer.parseInt(price));
            pvo.setStock(Integer.parseInt(stock));
            pvo.setPoint(Integer.parseInt(point));
            pvo.setYoutubeurl(youtubeurl);
            pvo.setProductdesc(productdesc);
            pvo.setProductimg(productimg);

            AdminDAO adao = new AdminDAO();
            int n = adao.insertProductWithTracks(pvo, trackTitles);
            
            // ... (결과 처리 로직은 기존과 동일) ...
            String message = (n==1)? "등록 성공" : "등록 실패";
            String loc = (n==1)? request.getContextPath()+"/admin/admin_product.lp" : "javascript:history.back()";
            
            request.setAttribute("message", message);
            request.setAttribute("loc", loc);
            super.setRedirect(false);
            super.setViewPage("/WEB-INF/msg.jsp");
        }
    }
}