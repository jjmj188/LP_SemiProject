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

   // 월별 조회 기본값 (이번달, 6개월 전)
   const today = new Date();
   const mm = String(today.getMonth() + 1).padStart(2, '0');
   const yyyy = today.getFullYear();
   $("#endDate").val(`${yyyy}-${mm}`); // 종료일: 이번 달
   
   // 시작일: 6개월 전으로 셋팅
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
         "searchType": type
     };

     // --- 유효성 검사 및 데이터 세팅 ---
     if (type === 'month') {
       const sVal = $("#startDate").val(); 
       const eVal = $("#endDate").val();

       if (!sVal || !eVal) { alert("기간을 선택해주세요."); return; }
       
       if (sVal > eVal) { alert("종료일이 시작일보다 빠릅니다."); return; }

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
        // [중요] Command.properties에 등록한 AJAX 전용 URL로 변경
        url: "accountChart.lp", 
        type: "GET",
        data: requestData,
        dataType: "json", 
        success: function(json) {
            
            const $bars = $("#chartBars");
            const $labels = $("#chartLabels");

            $bars.empty();
            $labels.empty();

            if (!json || json.length === 0) {
               $bars.html('<div style="width:100%; text-align:center; margin-top:130px; color:#999;">조회된 데이터가 없습니다.</div>');
               return; 
            }

            drawBars(json);
        },
        error: function(request, status, error){
            console.error("code:"+request.status+"\n"+"message:"+request.responseText+"\n"+"error:"+error);
            alert("데이터 조회 중 오류가 발생했습니다.");
        }
     });

     // --- 차트 그리기 함수 (내부) ---
     function drawBars(data) {
       const $bars = $("#chartBars");
       const $labels = $("#chartLabels");

       // 1. 최대값 구하기 (그래프 높이 비율 100% 기준점)
       const maxAmount = Math.max(...data.map(d => Number(d.amount)));
       
       if (maxAmount === 0) {
           $bars.html('<div style="width:100%; text-align:center; margin-top:130px; color:#999;">매출 내역이 없습니다 (0원).</div>');
           return;
       }

       data.forEach(d => {
         const amt = Number(d.amount);
         
         // 2. 높이 비율 계산 (최소 5% 보장)
         let percent = 0;
         if(amt > 0) {
             percent = (amt / maxAmount) * 100;
             if(percent < 5) percent = 5; 
         }

         // 3. 금액 포맷팅 (3자리 콤마)
         const formatAmount = amt.toLocaleString();
         
         // 4. 막대 생성
         // .bar 클래스는 JSP 내부 <style>에 정의되어 있어야 함
         const barHtml = `<div class="bar" style="height:${percent}%;" title="${d.label}: ${formatAmount}원"></div>`;
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
   
   // 페이지 로딩 시 자동으로 1회 실행
   renderChart();
   
});