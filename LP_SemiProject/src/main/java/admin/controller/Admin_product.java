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
        String mode = request.getParameter("mode"); // 기능 분기용 파라미터

        InterAdminDAO adao = new AdminDAO();

        // 1. 상품 등록 (POST & mode=register)
        if ("POST".equalsIgnoreCase(method) && "register".equals(mode)) {
            registerProduct(request, response, adao);
        }
        // 2. 상품 수정 (POST & mode=edit) [추가된 부분]
        else if ("POST".equalsIgnoreCase(method) && "edit".equals(mode)) {
            editProduct(request, response, adao);
        }
        // 3. 상품 삭제 (POST & mode=delete)
        else if ("POST".equalsIgnoreCase(method) && "delete".equals(mode)) {
            deleteProduct(request, response, adao);
        }
        // 4. 상품 목록 조회 (기본 GET)
        else {
            listProduct(request, response, adao);
        }
    }

    // [기능 1] 상품 목록 조회
    private void listProduct(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        String str_currentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 0;
        
        try {
            if(str_currentShowPageNo == null) currentShowPageNo = 1;
            else currentShowPageNo = Integer.parseInt(str_currentShowPageNo);
        } catch(NumberFormatException e) {
            currentShowPageNo = 1;
        }
        
        int sizePerPage = 10; 
        Map<String, String> paraMap = new HashMap<>();
        
        int totalCount = adao.getTotalProductCount(paraMap); 
        int totalPage = (int) Math.ceil((double)totalCount/sizePerPage);
        
        if(currentShowPageNo < 1) currentShowPageNo = 1;
        if(currentShowPageNo > totalPage) currentShowPageNo = totalPage;
        
        int startRno = ((currentShowPageNo - 1) * sizePerPage) + 1;
        int endRno = startRno + sizePerPage - 1;
        
        paraMap.put("startRno", String.valueOf(startRno));
        paraMap.put("endRno", String.valueOf(endRno));
        
        List<ProductVO> productList = adao.getProductListWithPaging(paraMap);
        
        // 페이지바
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
        request.setAttribute("totalCount", totalCount);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_product.jsp");
    }

    // [기능 2] 상품 등록
    private void registerProduct(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        ServletContext svlCtx = request.getSession().getServletContext();
        String uploadFileDir = svlCtx.getRealPath("/images/productimg");
        File dir = new File(uploadFileDir);
        if (!dir.exists()) { dir.mkdirs(); }

        String fk_categoryno = request.getParameter("fk_categoryno");
        String productname = request.getParameter("productname");
        String price = request.getParameter("price");
        String stock = request.getParameter("stock");
        String point = request.getParameter("point");
        String youtubeurl = request.getParameter("youtubeurl");
        String productdesc = request.getParameter("productdesc");

        String productimg = null;
        try {
            Part filePart = request.getPart("productimg");
            if (filePart != null && filePart.getSize() > 0) {
                String originName = filePart.getSubmittedFileName();
                String ext = originName.substring(originName.lastIndexOf("."));
                String saveName = UUID.randomUUID().toString() + ext;
                filePart.write(uploadFileDir + File.separator + saveName);
                productimg = saveName;
            }
        } catch(Exception e) { e.printStackTrace(); }

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

    // [기능 3] 상품 수정 (재고량 변경 등)
    private void editProduct(HttpServletRequest request, HttpServletResponse response, InterAdminDAO adao) throws Exception {
        
        ServletContext svlCtx = request.getSession().getServletContext();
        String uploadFileDir = svlCtx.getRealPath("/images/productimg");

        // PK 및 수정 데이터 받기
        String productno = request.getParameter("productno");
        String fk_categoryno = request.getParameter("fk_categoryno");
        String productname = request.getParameter("productname");
        String price = request.getParameter("price");
        String stock = request.getParameter("stock");
        String point = request.getParameter("point");
        String youtubeurl = request.getParameter("youtubeurl");
        String productdesc = request.getParameter("productdesc");

        String productimg = null;
        try {
            Part filePart = request.getPart("productimg");
            if (filePart != null && filePart.getSize() > 0) {
                String originName = filePart.getSubmittedFileName();
                String ext = originName.substring(originName.lastIndexOf("."));
                String saveName = UUID.randomUUID().toString() + ext;
                filePart.write(uploadFileDir + File.separator + saveName);
                productimg = saveName; // 이미지가 변경된 경우
            }
        } catch(Exception e) { e.printStackTrace(); }

        ProductVO pvo = new ProductVO();
        pvo.setProductno(Integer.parseInt(productno));
        pvo.setFk_categoryno(Integer.parseInt(fk_categoryno));
        pvo.setProductname(productname);
        pvo.setPrice(Integer.parseInt(price));
        pvo.setStock(Integer.parseInt(stock));
        pvo.setPoint(Integer.parseInt(point));
        pvo.setYoutubeurl(youtubeurl);
        pvo.setProductdesc(productdesc);
        
        // 이미지가 null이면 DAO에서 기존 값을 유지하도록 처리됨 (UPDATE 쿼리 확인 필요)
        if(productimg != null) {
            pvo.setProductimg(productimg);
        }

        int n = adao.updateProduct(pvo); // DAO의 updateProduct 호출

        String message = (n == 1) ? "상품 정보가 수정되었습니다." : "상품 수정에 실패했습니다.";
        String loc = request.getContextPath() + "/admin/admin_product.lp";

        request.setAttribute("message", message);
        request.setAttribute("loc", loc);
        
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/msg.jsp");
    }

    // [기능 4] 상품 삭제
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