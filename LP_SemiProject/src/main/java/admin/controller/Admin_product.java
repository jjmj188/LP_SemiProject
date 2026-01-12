package admin.controller;

import java.io.File;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.UUID;

import common.controller.AbstractController;
import jakarta.servlet.ServletContext;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import admin.model.AdminDAO;
import admin.model.InterAdminDAO;
import admin.model.ProductVO;

public class Admin_product extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        String method = request.getMethod();
        String mode = request.getParameter("mode"); // 기능 분기용 파라미터 (register, delete)

        InterAdminDAO adao = new AdminDAO();

        // 1. 상품 등록 (POST 방식 & mode=register)
        // [주의] JSP 폼 태그에 action="admin_product.lp?mode=register" 또는 hidden input 필요
        if ("POST".equalsIgnoreCase(method) && "register".equals(mode)) {
            registerProduct(request, response, adao);
        }
        // 2. 상품 삭제 (POST 방식 & mode=delete)
        else if ("POST".equalsIgnoreCase(method) && "delete".equals(mode)) {
            deleteProduct(request, response, adao);
        }
        // 3. 상품 목록 조회 (기본 GET 방식)
        else {
            listProduct(request, response, adao);
        }
    }

    // [기능 1] 상품 목록 조회
    private void listProduct(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        // 1. 페이징 처리를 위한 현재 페이지 번호
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 0;
        
        try {
            if(str_currentShowPageNo == null) currentShowPageNo = 1;
            else currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
        } catch(NumberFormatException e) {
            currentShowPageNo = 1;
        }
        
        int sizePerPage = 10; // 한 페이지당 보여줄 상품 개수
        
        Map<String, String> paraMap = new HashMap<>();
        
        // 검색 기능이 있다면 여기에 추가
        // String searchWord = request.getParameter("searchWord");
        // if(searchWord != null) paraMap.put("searchWord", searchWord);

        int totalCount = adao.getTotalProductCount(paraMap); 
        int totalPage = (int) Math.ceil((double)totalCount/sizePerPage);
        
        if(currentShowPageNo < 1) currentShowPageNo = 1;
        if(currentShowPageNo > totalPage) currentShowPageNo = totalPage;
        
        int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
        int endRno = startRno + sizePerPage - 1;
        
        paraMap.put("startRno", String.valueOf(startRno));
        paraMap.put("endRno", String.valueOf(endRno));
        
        List<ProductVO> productList = adao.getProductListWithPaging(paraMap);
        
        // 페이지바 생성 로직
        String pageBar = "";
        int blockSize = 10;
        int loop = 1;
        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        
        String url = "admin_product.lp";
        
        if(pageNo != 1) {
            pageBar += "<a href='"+url+"?currentShowPageNo="+(pageNo-1)+"' class='direction'>&lt;</a>";
        }
        
        while( !(loop > blockSize || pageNo > totalPage) ) {
            if(pageNo == currentShowPageNo) {
                pageBar += "<span class='active'>"+pageNo+"</span>";
            } else {
                pageBar += "<a href='"+url+"?currentShowPageNo="+pageNo+"'>"+pageNo+"</a>";
            }
            loop++;
            pageNo++;
        }
        
        if(pageNo <= totalPage) {
            pageBar += "<a href='"+url+"?currentShowPageNo="+pageNo+"' class='direction'>&gt;</a>";
        }
        
        request.setAttribute("productList", productList);
        request.setAttribute("pageBar", pageBar);
        request.setAttribute("totalCount", totalCount); // 총 상품 수도 뷰단에 전달
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_product.jsp");
    }

    // [기능 2] 상품 등록
    private void registerProduct(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        // 파일 저장 경로 설정
        ServletContext svlCtx = request.getSession().getServletContext();
        String uploadFileDir = svlCtx.getRealPath("/images/productimg");

        File dir = new File(uploadFileDir);
        if (!dir.exists()) { dir.mkdirs(); } // 폴더 없으면 생성

        // 파라미터 받기
        String fk_categoryno = request.getParameter("fk_categoryno");
        String productname = request.getParameter("productname");
        String price = request.getParameter("price");
        String stock = request.getParameter("stock");
        String point = request.getParameter("point");
        String youtubeurl = request.getParameter("youtubeurl");
        String productdesc = request.getParameter("productdesc");

        // 파일 업로드 처리 (Part API)
        String productimg = null;
        try {
            Part filePart = request.getPart("productimg");
            
            if (filePart != null && filePart.getSize() > 0) {
                String originName = filePart.getSubmittedFileName();
                String ext = originName.substring(originName.lastIndexOf("."));
                String saveName = UUID.randomUUID().toString() + ext; // 파일명 중복 방지
                
                filePart.write(uploadFileDir + File.separator + saveName);
                productimg = saveName;
            }
        } catch(Exception e) {
            e.printStackTrace(); // 파일이 없거나 오류 발생 시 처리
        }

        String[] trackTitles = request.getParameterValues("track_title");

        ProductVO pvo = new ProductVO();
        pvo.setFk_categoryno(Integer.parseInt(fk_categoryno));
        pvo.setProductname(productname);
        pvo.setPrice(Integer.parseInt(price));
        pvo.setStock(Integer.parseInt(stock));
        pvo.setPoint(Integer.parseInt(point));
        pvo.setYoutubeurl(youtubeurl);
        pvo.setProductdesc(productdesc);
        pvo.setProductimg(productimg);

        int n = adao.insertProductWithTracks(pvo, trackTitles);

        String message = (n == 1) ? "상품이 등록되었습니다." : "상품 등록에 실패했습니다.";
        String loc = (n == 1) ? request.getContextPath() + "/admin/admin_product.lp" : "javascript:history.back()";

        request.setAttribute("message", message);
        request.setAttribute("loc", loc);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp");
    }

    // [기능 3] 상품 삭제
    private void deleteProduct(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        String[] pnums = request.getParameterValues("pseq");

        String message = "";
        String loc = "";

        if (pnums != null && pnums.length > 0) {
            int n = adao.deleteProduct(pnums);

            if (n == 1) {
                message = "선택한 상품이 삭제되었습니다.";
                loc = request.getContextPath() + "/admin/admin_product.lp";
            } else {
                message = "삭제 실패";
                loc = "javascript:history.back()";
            }
        } else {
            message = "선택된 상품이 없습니다.";
            loc = "javascript:history.back()";
        }

        request.setAttribute("message", message);
        request.setAttribute("loc", loc);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp");
    }
}