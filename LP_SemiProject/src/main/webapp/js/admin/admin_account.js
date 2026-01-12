$(document).ready(function() {
    
    // 1. 초기화 작업: 날짜 및 연도 셀렉트 박스 세팅
    initDateControls();

    // 2. 조회 기준(월별/연도별) 변경 시 UI 토글
    $("#searchType").change(function() {
        const type = $(this).val();
        if(type === "month") {
            $(".box-month").show();
            $(".box-year").hide();
        } else {
            $(".box-month").hide();
            $(".box-year").show();
        }
    });

    // 3. [조회하기] 버튼 클릭 시 AJAX 요청
    $("#btnSearch").click(function() {
        const searchType = $("#searchType").val();
        
        // 파라미터 객체 생성 (mode: 'chartData' 필수)
        let params = { "searchType": searchType, "mode": "chartData" }; 

        // 유효성 검사 및 파라미터 세팅
        if(searchType === "month") {
            const start = $("#startDate").val();
            const end = $("#endDate").val();
            
            if(!start || !end) { 
                alert("조회 기간을 선택해주세요."); 
                return; 
            }
            if(start > end) { 
                alert("시작일이 종료일보다 클 수 없습니다."); 
                return; 
            }
            
            params.startDate = start;
            params.endDate = end;
        } else {
            const startYear = $("#startYearSelect").val();
            const endYear = $("#endYearSelect").val();
            
            if(Number(startYear) > Number(endYear)) { 
                alert("시작 연도가 종료 연도보다 클 수 없습니다."); 
                return; 
            }

            params.startYear = startYear;
            params.endYear = endYear;
        }

        // AJAX 호출
        $.ajax({
            url: "admin_account.lp", // 상대 경로 사용 (현재 페이지와 동일한 컨트롤러)
            type: "GET",
            data: params,
            dataType: "json",
            success: function(json) {
                renderChart(json); // 차트 그리기 함수 호출
            },
            error: function(xhr, status, error) {
                console.error("AJAX Error:", error);
                alert("데이터 조회 중 오류가 발생했습니다.");
            }
        });
    });
    
    // (선택사항) 페이지 로드 시 자동으로 조회 버튼 클릭 트리거
    // $("#btnSearch").trigger("click");

}); // end of $(document).ready


// ============================================
//  함수 정의 영역
// ============================================

/**
 * 날짜(월) 및 연도 선택 컨트롤의 초기값을 설정하는 함수
 */
function initDateControls() {
    // 1. 월별 조회 초기값 설정 (현재 달 ~ 5개월 전)
    const now = new Date();
    const year = now.getFullYear();
    const month = String(now.getMonth() + 1).padStart(2, '0');
    const currentMonth = year + "-" + month;
    
    // 5개월 전 계산
    const pastDate = new Date();
    pastDate.setMonth(pastDate.getMonth() - 5);
    const pastYear = pastDate.getFullYear();
    const pastMon = String(pastDate.getMonth() + 1).padStart(2, '0');
    const startMonth = pastYear + "-" + pastMon;

    // input type="month"에 값 할당
    $("#startDate").val(startMonth);
    $("#endDate").val(currentMonth);

    // 2. 연도별 조회 옵션 생성 (최근 10년)
    const currentYear = new Date().getFullYear();
    let yearOptions = "";
    for(let y = currentYear; y >= currentYear - 10; y--) {
        yearOptions += '<option value="'+y+'">'+y+'년</option>';
    }
    
    $("#startYearSelect").html(yearOptions);
    $("#endYearSelect").html(yearOptions);
    
    // 기본값: 시작(4년 전) ~ 끝(현재)
    $("#endYearSelect").val(currentYear);
    $("#startYearSelect").val(currentYear - 4);
}

/**
 * JSON 데이터를 받아 막대 그래프를 그리는 함수
 * @param {Array} dataList - [{label: '2025-01', amount: '10000'}, ...]
 */
function renderChart(dataList) {
    const $bars = $("#chartBars");
    const $labels = $("#chartLabels");
    
    // 기존 내용 초기화
    $bars.empty();
    $labels.empty();

    // 데이터가 없거나 비어있는 경우 처리
    if(!dataList || dataList.length === 0) {
        $bars.removeClass("has-data");
        $bars.html('<div style="margin: auto; color: #999;">조회된 데이터가 없습니다.</div>');
        return;
    }

    $bars.addClass("has-data");

    // 1. Y축 비율 계산을 위해 최대값(Max Value) 찾기
    let maxVal = 0;
    dataList.forEach(item => {
        // DB에서 가져온 값이 문자열일 수 있으므로 숫자로 변환
        const val = Number(item.amount); 
        if(val > maxVal) maxVal = val;
    });
    
    if(maxVal === 0) maxVal = 1; // 0 나누기 방지

    // 2. 데이터를 순회하며 막대(Bar) 생성
    dataList.forEach(item => {
        const val = Number(item.amount);
        
        // 높이 비율 계산 (최대 높이의 90%까지만 차도록 설정)
        const heightPercent = (val / maxVal) * 90; 
        
        // 금액 포맷팅 (예: 10000 -> 10,000)
        const formattedVal = val.toLocaleString();

        // 막대 HTML 생성
        // 최소 높이 1% 보장 (값이 0이어도 선은 보이게)
        const displayHeight = heightPercent === 0 ? 1 : heightPercent;

        let html = '';
        html += '<div class="bar-container">';
        html += '   <div class="bar" style="height: '+ displayHeight +'%;" title="'+ item.label +' : '+ formattedVal +'원"></div>';
        html += '   <div class="bar-tooltip">'+ formattedVal +'</div>';
        html += '</div>';

        $bars.append(html);

        // 하단 라벨(날짜/연도) 추가
        $labels.append('<div class="label-item">'+ item.label +'</div>');
    });
}