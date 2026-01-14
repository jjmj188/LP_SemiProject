package index.controller;

import java.util.ArrayList;
import java.util.List;

import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import member.domain.MemberDTO;
import member.model.MemberDAO;
import member.model.MemberDAO_imple;
import product.domain.ProductDTO;
import product.model.ProductDAO;
import product.model.ProductDAO_imple;

public class IndexController extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {

        ProductDAO pdao = new ProductDAO_imple();

        // 1. 파라미터 받기
        String strCategoryNo = request.getParameter("categoryno");
        int categoryNo = 0;
        if(strCategoryNo != null) {
            try { categoryNo = Integer.parseInt(strCategoryNo); } catch(Exception e) {}
        }

        String searchWord = request.getParameter("q");
        if(searchWord == null) searchWord = ""; 

        String sortType = request.getParameter("sort");
        if(sortType == null || sortType.isEmpty()) {
            sortType = "latest"; 
        }
        
        // 2. 페이징 처리 변수
        String strCurrentShowPageNo = request.getParameter("currentShowPageNo");
        int currentShowPageNo = 1;
        int sizePerPage = 8; 
        int blockSize = 10; // 페이지바에 보여줄 페이지 개수 (1~10)
        
        if(strCurrentShowPageNo != null) {
            try {
                currentShowPageNo = Integer.parseInt(strCurrentShowPageNo);
            } catch(Exception e) {}
        }
        
        int totalCount = pdao.getTotalProductCount(categoryNo, searchWord);
        int totalPage = (int) Math.ceil((double)totalCount / sizePerPage);
        
        if (currentShowPageNo > totalPage && totalPage != 0) {
            currentShowPageNo = totalPage;
        }
        
        // 3. 상품 리스트 조회
        List<ProductDTO> productList = null;
        if(totalCount > 0) {
            productList = pdao.selectPagingProduct(currentShowPageNo, sizePerPage, categoryNo, searchWord, sortType);
        }

        // 페이지바 생성
        String pageBar = makePageBar(currentShowPageNo, totalPage, blockSize, categoryNo, searchWord, sortType, request.getContextPath());
        request.setAttribute("pageBar", pageBar);

        request.setAttribute("productList", productList);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("currentPage", currentShowPageNo);
        request.setAttribute("categoryNo", categoryNo);
        request.setAttribute("searchWord", searchWord);
        request.setAttribute("sort", sortType);
        
        List<ProductDTO> newProductList = pdao.selectNewProductList();
        request.setAttribute("newProductList", newProductList);

        List<ProductDTO> recommendList = new ArrayList<>();
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
        
        if (loginuser == null) {
            recommendList = pdao.selectRandomRecommendation();
        } else {
            MemberDAO mdao = new MemberDAO_imple();
            List<Integer> myTaste = mdao.getUserPreference(loginuser.getUserid());
            
            if(myTaste == null || myTaste.size() == 0) {
                recommendList = pdao.selectRandomRecommendation();
            } else {
                int[] counts;
                switch (myTaste.size()) {
                    case 1: counts = new int[]{5}; break;
                    case 2: counts = new int[]{3, 2}; break;
                    case 3: counts = new int[]{2, 2, 1}; break;
                    case 4: counts = new int[]{2, 1, 1, 1}; break;
                    case 5: counts = new int[]{1, 1, 1, 1, 1}; break;
                    default: counts = new int[]{1, 1, 1, 1, 1}; break;
                }
                for(int i=0; i<myTaste.size(); i++) {
                    if(i >= counts.length) break;
                    recommendList.addAll(pdao.selectProductsByCategory(myTaste.get(i), counts[i])); 
                }
            }
        }
        request.setAttribute("recommendList", recommendList);
        
        setRedirect(false);
        setViewPage("/WEB-INF/index.jsp");
    }

    // 메인페이지용 페이지바 생성 메서드
    private String makePageBar(int currentShowPageNo, int totalPage, int blockSize, int categoryNo, String searchWord, String sortType, String ctxPath) {
        if (totalPage == 0) return "";

        int pageNo = ((currentShowPageNo - 1) / blockSize) * blockSize + 1;
        int loop = 1;

        String url = ctxPath + "/index.lp?categoryno=" + categoryNo + "&q=" + searchWord + "&sort=" + sortType + "&currentShowPageNo=";
        String anchor = "#product-list"; // 이동할 위치
        
        StringBuilder sb = new StringBuilder();

        // [맨처음]
        sb.append("<li class='page-item'><button class='page-btn first' " + (currentShowPageNo == 1 ? "disabled" : "onclick=\"location.href='" + url + "1" + anchor + "'\"") + "><span>맨처음</span></button></li>");
        
        // [이전]
        sb.append("<li class='page-item'><button class='page-btn prev' " + (currentShowPageNo == 1 ? "disabled" : "onclick=\"location.href='" + url + (currentShowPageNo - 1) + anchor + "'\"") + "><i class='fa-solid fa-chevron-left'></i></button></li>");

        // [번호]
        while (!(loop > blockSize || pageNo > totalPage)) {
            if (pageNo == currentShowPageNo) {
                sb.append("<li class='page-item'><button class='page-num active'>" + pageNo + "</button></li>");
            } else {
                
                sb.append("<li class='page-item'><button class='page-num' onclick=\"location.href='" + url + pageNo + anchor + "'\">" + pageNo + "</button></li>");
            }
            loop++;
            pageNo++;
        }

        // [다음]
        sb.append("<li class='page-item'><button class='page-btn next' " + (currentShowPageNo == totalPage ? "disabled" : "onclick=\"location.href='" + url + (currentShowPageNo + 1) + anchor + "'\"") + "><i class='fa-solid fa-chevron-right'></i></button></li>");
        
        // [맨마지막]
        sb.append("<li class='page-item'><button class='page-btn last' " + (currentShowPageNo == totalPage ? "disabled" : "onclick=\"location.href='" + url + totalPage + anchor + "'\"") + "><span>맨마지막</span></button></li>");

        return sb.toString();
    }
}