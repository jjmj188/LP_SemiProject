$(function () {
   $("#header").load("../common/header.html");
   $("#footer").load("../common/footer.html");

   // 초기 연도 설정
   const startYearLoop = 2022;
   const currentYear = new Date().getFullYear(); 
   const endYearLoop = currentYear + 5; 

   for (let y = startYearLoop; y <= endYearLoop; y++) {
     $("#startYearSelect, #endYearSelect").append(`<option value="${y}">${y}년</option>`);
   }
   $("#startYearSelect").val(2022);
   $("#endYearSelect").val(2024);

   // ==========================================
   // 3. 매출 데이터 (2025년 12월까지만 존재)
   // ==========================================
   const salesData = [
     // 2022년
     { year: 2022, month: 1, amount: 8400000 }, { year: 2022, month: 2, amount: 8100000 },
     { year: 2022, month: 3, amount: 9500000 }, { year: 2022, month: 4, amount: 9200000 },
     { year: 2022, month: 5, amount: 10800000 }, { year: 2022, month: 6, amount: 10500000 },
     { year: 2022, month: 7, amount: 11200000 }, { year: 2022, month: 8, amount: 10900000 },
     { year: 2022, month: 9, amount: 12100000 }, { year: 2022, month: 10, amount: 11800000 },
     { year: 2022, month: 11, amount: 12500000 }, { year: 2022, month: 12, amount: 14200000 },
     // 2023년
     { year: 2023, month: 1, amount: 13500000 }, { year: 2023, month: 2, amount: 13100000 },
     { year: 2023, month: 3, amount: 14500000 }, { year: 2023, month: 4, amount: 14200000 },
     { year: 2023, month: 5, amount: 15800000 }, { year: 2023, month: 6, amount: 15100000 },
     { year: 2023, month: 7, amount: 14800000 }, { year: 2023, month: 8, amount: 14500000 },
     { year: 2023, month: 9, amount: 16200000 }, { year: 2023, month: 10, amount: 15900000 },
     { year: 2023, month: 11, amount: 16800000 }, { year: 2023, month: 12, amount: 18500000 },
     // 2024년
     { year: 2024, month: 1, amount: 15400000 }, { year: 2024, month: 2, amount: 14800000 },
     { year: 2024, month: 3, amount: 16200000 }, { year: 2024, month: 4, amount: 15900000 },
     { year: 2024, month: 5, amount: 18500000 }, { year: 2024, month: 6, amount: 17200000 },
     { year: 2024, month: 7, amount: 16500000 }, { year: 2024, month: 8, amount: 15800000 },
     { year: 2024, month: 9, amount: 19400000 }, { year: 2024, month: 10, amount: 18900000 },
     { year: 2024, month: 11, amount: 21000000 }, { year: 2024, month: 12, amount: 23500000 },
     // 2025년
     { year: 2025, month: 1, amount: 20500000 }, { year: 2025, month: 2, amount: 19800000 },
     { year: 2025, month: 3, amount: 21500000 }, { year: 2025, month: 4, amount: 21000000 },
     { year: 2025, month: 5, amount: 23800000 }, { year: 2025, month: 6, amount: 22500000 },
     { year: 2025, month: 7, amount: 21800000 }, { year: 2025, month: 8, amount: 20500000 },
     { year: 2025, month: 9, amount: 24200000 }, { year: 2025, month: 10, amount: 23900000 },
     { year: 2025, month: 11, amount: 25500000 }, { year: 2025, month: 12, amount: 26800000 }
   ];

   $("#searchType").on("change", function() {
     const type = $(this).val();
     if (type === 'year') {
       $(".box-month").hide(); $(".box-year").show();
     } else {
       $(".box-year").hide(); $(".box-month").show();
     }
   });

   function renderChart() {
     const type = $("#searchType").val(); 
     let startY, startM, endY, endM;

     // 1. 기간 선택 파싱
     if (type === 'month') {
       const sVal = $("#startDate").val(); 
       const eVal = $("#endDate").val();
       if (!sVal || !eVal) { alert("기간을 선택해주세요."); return; }

       startY = parseInt(sVal.split("-")[0]);
       startM = parseInt(sVal.split("-")[1]);
       endY = parseInt(eVal.split("-")[0]);
       endM = parseInt(eVal.split("-")[1]);

       const diff = (endY - startY) * 12 + (endM - startM);
       if (diff < 0) { alert("종료일이 시작일보다 빠릅니다."); return; }
       if (diff > 11) { alert("월별 조회는 최대 12개월까지만 가능합니다."); return; }
     } else {
       startY = parseInt($("#startYearSelect").val());
       endY = parseInt($("#endYearSelect").val());
       startM = 1; endM = 12;

       const diffYear = endY - startY;
       if (diffYear < 0) { alert("종료 연도가 시작 연도보다 빠릅니다."); return; }
       if (diffYear > 2) { alert("연도별 조회는 최대 3년까지만 가능합니다."); return; }
     }

     // =========================================================
     // [로직 추가] 선택한 종료일이 DB의 마지막 날짜를 초과했는지 확인
     // =========================================================
     
     // 1) DB상의 가장 마지막 데이터 날짜 찾기 (데이터가 정렬되어 있다고 가정 시 마지막 요소)
     const lastData = salesData[salesData.length - 1];
     const maxDataYear = lastData.year;
     const maxDataMonth = lastData.month;
     
     // 2) 날짜 비교를 위해 '총 월수'로 환산 (년*12 + 월)
     const userEndTime = endY * 12 + endM;
     const maxDataTime = maxDataYear * 12 + maxDataMonth;

     // 3) 사용자 종료일이 데이터 마지막 날짜보다 크면 경고창 띄우기 (return은 하지 않음)
     if (userEndTime > maxDataTime) {
       alert(`${maxDataYear}년 ${maxDataMonth}월 이후의 데이터가 없습니다.`);
     }

     // 4. 데이터 필터링 (있는 구간만 남음)
     let filtered = salesData.filter(d => {
       const isAfterStart = (d.year > startY) || (d.year === startY && d.month >= startM);
       const isBeforeEnd = (d.year < endY) || (d.year === endY && d.month <= endM);
       return isAfterStart && isBeforeEnd;
     });

     // 5. 차트 그리기
     const $bars = $("#chartBars");
     const $labels = $("#chartLabels");

     $bars.empty();
     $labels.empty();

     if (filtered.length === 0) {
       // 아예 겹치는 구간이 하나도 없는 경우 (예: 2027년 조회 등)
       $bars.html('<div style="width:100%; text-align:center; margin-top:100px; color:#999;">데이터가 없습니다.</div>');
       return; 
     }

     if (type === 'year') {
       const yearMap = {};
       filtered.forEach(d => {
         if (!yearMap[d.year]) yearMap[d.year] = 0;
         yearMap[d.year] += d.amount;
       });
       const yearResult = Object.keys(yearMap).map(y => ({
         label: y + "년", amount: yearMap[y]
       }));
       drawBars(yearResult);
     } else {
       const monthResult = filtered.map(d => ({
         label: d.month + "월", amount: d.amount
       }));
       drawBars(monthResult);
     }

     function drawBars(data) {
       if (data.length === 0) return;
       const maxAmount = Math.max(...data.map(d => d.amount));
       data.forEach(d => {
         const percent = Math.max((d.amount / maxAmount) * 100, 5);
         const formatAmount = d.amount.toLocaleString() + "원";
         $bars.append(`<div class="bar" style="height:${percent}%" title="${d.label}: ${formatAmount}"></div>`);
         $labels.append(`<span>${d.label}</span>`);
       });
     }
   }

   $("#btnSearch").on("click", function() { renderChart(); });
   renderChart();
 });