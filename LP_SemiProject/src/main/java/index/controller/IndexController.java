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

        // 카테고리 번호 받기
        String strCategoryNo = request.getParameter("categoryno");
        int categoryNo = 0; // 0 = 전체 보기

        if(strCategoryNo != null) {
            try {
                categoryNo = Integer.parseInt(strCategoryNo);
            } catch(Exception e) {}
        }

        // 검색어 받기
        String searchWord = request.getParameter("q");
        
        // 정렬 기준 받기
        String sortType = request.getParameter("sort");
        if(sortType == null || sortType.isEmpty()) {
            sortType = "latest"; // 기본값
        }
        
        // 페이지 번호 받기
        String strPageNo = request.getParameter("pageNo");
        int currentShowPageNo = 1;
        int sizePerPage = 8;
        
        if(strPageNo != null) {
            try {
                currentShowPageNo = Integer.parseInt(strPageNo);
            } catch(Exception e) {}
        }
        
        // 전체 게시물 수 계산 & 페이징 처리
        int totalCount = pdao.getTotalProductCount(categoryNo, searchWord);
        int totalPage = (int) Math.ceil((double)totalCount / sizePerPage);
        
        if (currentShowPageNo > totalPage && totalPage != 0) {
            currentShowPageNo = totalPage;
        }
        
        // 메인 상품 리스트 가져오기 (카테고리 + 검색 + 정렬 + 페이징)
        List<ProductDTO> productList = null;
        if(totalCount > 0) {
            productList = pdao.selectPagingProduct(currentShowPageNo, sizePerPage, categoryNo, searchWord, sortType);
        }

        request.setAttribute("productList", productList);
        request.setAttribute("totalPage", totalPage);
        request.setAttribute("currentPage", currentShowPageNo);
        
        request.setAttribute("categoryNo", categoryNo);
        request.setAttribute("searchWord", searchWord);
        request.setAttribute("sort", sortType);
        
        // 상단 신상품(NEW) 섹션용 (10개)
        List<ProductDTO> newProductList = pdao.selectNewProductList();
        request.setAttribute("newProductList", newProductList);


        // MUSIC FOR YOU (취향 기반 추천) 로직 시작
        List<ProductDTO> recommendList = new ArrayList<>();
        
        // 로그인 유저 정보 가져오기
        HttpSession session = request.getSession();
        MemberDTO loginuser = (MemberDTO) session.getAttribute("loginuser");
        
        // 로그아웃 상태일 때: 랜덤 추천
        if (loginuser == null) {
            recommendList = pdao.selectRandomRecommendation();
        } 
        // 로그인 상태일 때: 취향 분석 추천
        else {
            MemberDAO mdao = new MemberDAO_imple();
            
            // [수정] 이미 만들어둔 getUserPreference 메소드 사용!
            List<Integer> myTaste = mdao.getUserPreference(loginuser.getUserid());
            
            // 취향 선택을 안 한 경우 -> 랜덤 추천
            if(myTaste == null || myTaste.size() == 0) {
                recommendList = pdao.selectRandomRecommendation();
            }
            else {
                // 취향 개수에 따른 분배 로직 (총 5개 맞추기)
                int[] counts;
                switch (myTaste.size()) {
                    case 1: counts = new int[]{5}; break;             // 1개 선택: 5개 몰빵
                    case 2: counts = new int[]{3, 2}; break;          // 2개 선택: 3개, 2개
                    case 3: counts = new int[]{2, 2, 1}; break;       // 3개 선택: 2개, 2개, 1개
                    case 4: counts = new int[]{2, 1, 1, 1}; break;    // 4개 선택: 2개, 1개...
                    case 5: counts = new int[]{1, 1, 1, 1, 1}; break; // 5개 선택: 각 1개
                    default: counts = new int[]{1, 1, 1, 1, 1}; break; // 예외 안전장치
                }
                
                // 각 취향 카테고리별로 할당된 개수만큼 뽑아와서 합치기
                for(int i=0; i<myTaste.size(); i++) {
                    // 혹시 취향 개수가 5개 넘어가면 루프 중단 (배열 인덱스 오류 방지)
                    if(i >= counts.length) break;
                    
                    int targetCategory = myTaste.get(i); // 카테고리 번호
                    int targetCount = counts[i];         // 가져올 개수
                    
                    List<ProductDTO> subList = pdao.selectProductsByCategory(targetCategory, targetCount);
                    recommendList.addAll(subList); 
                }
            }
        }
        
        request.setAttribute("recommendList", recommendList);

        
        setRedirect(false);
        setViewPage("/WEB-INF/index.jsp");
    }
}