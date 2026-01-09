package admin.controller;

import java.text.DecimalFormat;
import common.controller.AbstractController;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import admin.model.AdminDAO;

public class AdminAccountController extends AbstractController {

    @Override
    public void execute(HttpServletRequest request, HttpServletResponse response) throws Exception {
        
        AdminDAO adao = new AdminDAO();
        
        // 1. 숫자 데이터 가져오기
        int todaySales = adao.getTodaySales();
        int monthSales = adao.getMonthSales();
        long totalSales = adao.getTotalSales();
        
        // 2. 포맷팅 (3자리 콤마)
        DecimalFormat df = new DecimalFormat("#,###");
        
        request.setAttribute("s_todaySales", df.format(todaySales));
        request.setAttribute("s_monthSales", df.format(monthSales));
        request.setAttribute("s_totalSales", df.format(totalSales));
        
        // 3. 뷰 페이지 이동
        super.setRedirect(false);
        super.setViewPage("/WEB-INF/admin/admin_account.jsp"); // 경로 확인 필요
    }
}