$(function () {
    
   // ==========================================
   // 1. 초기 설정 (연도 옵션 생성 등)
   // ==========================================
   const currentYear = new Date().getFullYear(); 
   const startYearLoop = 2020; // 서비스 시작 연도
   const endYearLoop = currentYear; 

   // 연도 select 박스에 옵션 추가
   for (let y = startYearLoop; y <= endYearLoop; y++) {
     $("#startYearSelect, #endYearSelect").append(`<option value="${y}">${y}년</option>`);
   }
   
   // 기본값 설정 (최근 1년 또는 현재 연도)
   $("#startYearSelect").val(currentYear - 1); // 작년
   $("#endYearSelect").val(currentYear);       // 올해

   // 월별 조회 기본값 (이번달, 지난달 등 설정 가능)
   // HTML input type="month"는 value="YYYY-MM" 형식을 따름
   const today = new Date();
   const mm = String(today.getMonth() + 1).padStart(2, '0');
   const yyyy = today.getFullYear();
   $("#endDate").val(`${yyyy}-${mm}`); // 종료일: 이번 달
   
   // 시작일: 6개월 전으로 셋팅 예시
   const pastDate = new Date();
   pastDate.setMonth(pastDate.getMonth() - 6);
   const p_mm = String(pastDate.getMonth() + 1).padStart(2, '0');
   const p_yyyy = pastDate.getFullYear();
   $("#startDate").val(`${p_yyyy}-${p_mm}`);


   // ==========================================
   // 2. 검색 타입 변경 시 UI 제어
   // ==========================================
   $("#searchType").on("change", function() {
     const type = $(this).val();
     if (type === 'year') {
       $(".box-month").hide(); 
       $(".box-year").show();
     } else {
       $(".box-year").hide(); 
       $(".box-month").show();
     }
   });


   // ==========================================
   // 3. 차트 렌더링 함수 (AJAX 요청)
   // ==========================================
   function renderChart() {
     const type = $("#searchType").val(); // 'month' or 'year'
     
     // 컨트롤러로 보낼 데이터 객체
     let requestData = {
         "mode": "chartData",  // Controller 분기용 필수 파라미터
         "searchType": type
     };

     // --- 유효성 검사 및 데이터 세팅 ---
     if (type === 'month') {
       const sVal = $("#startDate").val(); 
       const eVal = $("#endDate").val();

       if (!sVal || !eVal) { alert("기간을 선택해주세요."); return; }
       
       // 날짜 비교 로직 (종료일이 시작일보다 빠른지 체크)
       if (sVal > eVal) { alert("종료일이 시작일보다 빠릅니다."); return; }

       // (선택) 12개월 이상 조회 제한 로직이 필요하다면 여기에 추가
       
       requestData.startDate = sVal;
       requestData.endDate = eVal;

     } else {
       // 연도별 조회
       const startY = parseInt($("#startYearSelect").val());
       const endY = parseInt($("#endYearSelect").val());

       if (startY > endY) { alert("종료 연도가 시작 연도보다 빠릅니다."); return; }

       requestData.startYear = startY;
       requestData.endYear = endY;
     }

     // --- AJAX 요청 ---
     $.ajax({
        url: "admin_account.lp", // 서블릿 매핑 주소 확인
        type: "GET",
        data: requestData,
        dataType: "json", // 서버에서 JSON 응답을 기대함
        success: function(json) {
            // json 예시: [{ "label": "2025-01", "amount": 1500000 }, ...]
            
            const $bars = $("#chartBars");
            const $labels = $("#chartLabels");

            $bars.empty();
            $labels.empty();

            if (!json || json.length === 0) {
               $bars.html('<div style="width:100%; text-align:center; margin-top:100px; color:#999;">조회된 데이터가 없습니다.</div>');
               return; 
            }

            drawBars(json);
        },
        error: function(request, status, error){
            console.error("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            alert("데이터 조회 중 오류가 발생했습니다. (로그 확인 필요)");
        }
     });

     // --- 차트 그리기 함수 (내부) ---
     function drawBars(data) {
       const $bars = $("#chartBars");
       const $labels = $("#chartLabels");

       // 1. 최대값 구하기 (그래프 높이 비율 100% 기준점)
       // 데이터가 문자열일 수 있으므로 Number()로 변환
       const maxAmount = Math.max(...data.map(d => Number(d.amount)));
       
       if (maxAmount === 0) {
           $bars.html('<div style="width:100%; text-align:center; margin-top:100px; color:#999;">매출 내역이 없습니다 (0원).</div>');
           return;
       }

       data.forEach(d => {
         const amt = Number(d.amount);
         
         // 2. 높이 비율 계산 (0원이면 0%, 값이 있으면 최소 5% 높이는 주어서 시각적으로 표시)
         let percent = 0;
         if(amt > 0) {
             percent = (amt / maxAmount) * 100;
             if(percent < 5) percent = 5; // 너무 작아서 안 보이는 것 방지
         }

         // 3. 금액 포맷팅 (3자리 콤마)
         const formatAmount = amt.toLocaleString() + "원";
         
         // 4. 막대 생성 (title 속성은 마우스 오버 시 툴팁 역할)
         const barHtml = `<div class="bar" style="height:${percent}%;" title="${d.label}: ${formatAmount}"></div>`;
         $bars.append(barHtml);

         // 5. 라벨 생성
         $labels.append(`<span>${d.label}</span>`);
       });
     }
   }

   // ==========================================
   // 4. 이벤트 등록
   // ==========================================
   
   // 조회 버튼 클릭 시 실행
   $("#btnSearch").on("click", function() { 
       renderChart(); 
   });
   
   // 페이지 로딩 시 자동으로 1회 실행 (초기 데이터 표시)
   renderChart();
   
});