// 차트 객체를 전역 변수로 선언 (재사용 및 삭제를 위해)
let myChart = null; 

$(document).ready(function(){
    
    // ==========================================
    // 1. 기본 날짜 및 연도 설정 (페이지 로드 시)
    // ==========================================
    
    // 1-1. 월별 조회 초기값: [5개월 전] ~ [현재]
    let now = new Date();
    let endStr = now.toISOString().slice(0, 7); // 현재 "YYYY-MM"
    
    now.setMonth(now.getMonth() - 5);
    let startStr = now.toISOString().slice(0, 7); // 5달 전 "YYYY-MM"
    
    $("#startDate").val(startStr);
    $("#endDate").val(endStr);
    
    // 1-2. 연도별 조회 초기값: 최근 5년 생성
    let currentYear = new Date().getFullYear();
    for(let i=0; i<5; i++) {
        let y = currentYear - i;
        // 내림차순으로 옵션 추가 (2025, 2024, 2023...)
        $("#startYear").append(`<option value="${y}">${y}년</option>`);
        $("#endYear").append(`<option value="${y}">${y}년</option>`);
    }
    // 시작은 4년 전, 끝은 현재 연도로 설정
    $("#startYear").val(currentYear - 4); 
    $("#endYear").val(currentYear);     

    // ==========================================
    // 2. 이벤트 리스너 등록
    // ==========================================

    // 검색 타입(월별/연도별) 변경 시 입력창 토글
    $("#searchType").change(function(){
        if($(this).val() == "month") {
            $("#monthRange").show();
            $("#yearRange").hide();
        } else {
            $("#monthRange").hide();
            $("#yearRange").show();
        }
    });

    // ==========================================
    // 3. 초기 차트 그리기
    // ==========================================
    updateChart();
});

// =======================================================
// [기능 1] AJAX로 차트 데이터 요청
// =======================================================
function updateChart() {
    
    let searchType = $("#searchType").val();
    
    // 컨트롤러에 보낼 파라미터 구성
    let param = {
        "mode": "chartData", // 컨트롤러에서 JSON 응답 분기용
        "searchType": searchType,
        "startDate": $("#startDate").val(),
        "endDate": $("#endDate").val(),
        "startYear": $("#startYear").val(),
        "endYear": $("#endYear").val()
    };

    // 유효성 검사 (월별 검색 시 시작일이 종료일보다 늦으면 경고)
    if(searchType === "month" && param.startDate > param.endDate) {
        alert("시작월이 종료월보다 늦을 수 없습니다.");
        return;
    }
    
    // 연도별 검색 시 유효성 검사
    if(searchType === "year" && parseInt(param.startYear) > parseInt(param.endYear)) {
        alert("시작연도가 종료연도보다 클 수 없습니다.");
        return;
    }

    $.ajax({
        url: ctxPath + "/admin/admin_account.lp", // JSP 상단에서 정의한 ctxPath 사용
        type: "GET",
        data: param,
        dataType: "json",
        success: function(json) {
            // 받아온 JSON 데이터로 차트 그리기 함수 호출
            drawChart(json);
        },
        error: function(request, status, error) {
            alert("차트 데이터를 불러오는데 실패했습니다.\ncode:" + request.status + "\nerror:" + error);
        }
    });
}

// =======================================================
// [기능 2] Chart.js를 이용한 차트 렌더링
// =======================================================
function drawChart(data) {
    
    // 1. 기존 차트가 있다면 파괴 (새로 그리기 위해)
    if(myChart != null) {
        myChart.destroy();
    }

    // 2. 데이터 파싱 (JSON Array -> Label Array, Data Array)
    let labels = [];
    let values = [];
    
    if(data && data.length > 0) {
        data.forEach(item => {
            labels.push(item.label);  // x축 (날짜/연도)
            values.push(item.amount); // y축 (매출액)
        });
    } else {
        // 데이터가 없을 경우 빈 차트 대신 메시지를 띄우거나 처리 가능
        // 여기서는 빈 차트가 그려짐
    }

    // 3. 캔버스 가져오기
    const ctx = document.getElementById('salesChart').getContext('2d');
    
    // 4. 차트 생성
    myChart = new Chart(ctx, {
        type: 'bar', // 차트 타입 (bar, line, pie 등)
        data: {
            labels: labels,
            datasets: [{
                label: '매출액',
                data: values,
                backgroundColor: 'rgba(51, 51, 51, 0.7)', // 막대 색상 (#333 투명도 조절)
                borderColor: 'rgba(51, 51, 51, 1)',
                borderWidth: 1,
                barPercentage: 0.6, // 막대 너비 조절
            }]
        },
        options: {
            responsive: true,
            maintainAspectRatio: false, // 부모 div 크기에 맞춤
            plugins: {
                legend: {
                    display: true,
                    position: 'top'
                },
                tooltip: {
                    // 툴팁(마우스 올렸을 때) 숫자 포맷팅 (콤마 + 원)
                    callbacks: {
                        label: function(context) {
                            let label = context.dataset.label || '';
                            if (label) {
                                label += ': ';
                            }
                            if (context.parsed.y !== null) {
                                // 12345 -> "12,345원" 변환
                                label += context.parsed.y.toLocaleString() + '원';
                            }
                            return label;
                        }
                    }
                }
            },
            scales: {
                y: {
                    beginAtZero: true,
                    ticks: {
                        // Y축 눈금 숫자 포맷팅 (콤마 + 원)
                        callback: function(value, index, values) {
                            if(value >= 100000000) return (value/100000000).toLocaleString() + "억원"; // 단위가 너무 크면 억 단위
                            return value.toLocaleString() + '원';
                        }
                    },
                    grid: {
                        color: '#f0f0f0' // 격자선 색상 연하게
                    }
                },
                x: {
                    grid: {
                        display: false // X축 세로 격자선 숨김
                    }
                }
            }
        }
    });
}