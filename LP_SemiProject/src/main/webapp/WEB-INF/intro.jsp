<%@ page language="java" contentType="text/html; charset=UTF-8"
    pageEncoding="UTF-8"%>
    
<%
	String ctxPath = request.getContextPath();
	// /LP_SemiProject
%>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8" />
  <meta name="viewport" content="width=device-width, initial-scale=1.0" />

  <style>
    /* 화면 중앙 고정 */
    .logo-wrap {
      background-color: #f2f2f2;
      position: fixed;
      inset: 0;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      gap: 16px;
      cursor: pointer;
    }

    .intro_logo img{
      margin-top: 100px;
      width: 250px;
    }

    /* ===== 여기서 크기/두께 조절 ===== */
    :root{
      --logo-size: 120px;
      --stroke: 4px;
      --draw-time: 5s;
      --fill-delay: 1.8s;
      --fill-time: 0.8s;
    }

    svg#logoSvg {
      width: min(900px, 92vw);
      height: auto;
      overflow: visible;
    }

    /* 텍스트 스타일 */
    #logoText {
      font-size: var(--logo-size);
      font-weight: 700;
      letter-spacing: 6px;

      fill: rgba(0, 0, 0, 0);
      stroke: #000;
      stroke-width: var(--stroke);
      stroke-linecap: round;
      stroke-linejoin: round;

      stroke-dasharray: 1400;
      stroke-dashoffset: 1400;

      animation:
        draw var(--draw-time) ease forwards,
        fillUp var(--fill-time) ease forwards;
      animation-delay:
        0s,
        var(--fill-delay);
    }

    @keyframes draw {
      to { stroke-dashoffset: 0; }
    }

    @keyframes fillUp {
      from { fill: rgba(0,0,0,0); }
      to   { fill: rgba(0,0,0,1); }
    }

    /* 확대 애니메이션 */
    .logo-wrap.zoom {
      animation: zoomOut 0.8s ease forwards;
    }

    @keyframes zoomOut {
      to {
        transform: scale(1.4);
        opacity: 0;
      }
    }

 
    .guide-text {
      margin-top: 12px;
      font-size: 13px;
      color: #666;
      letter-spacing: 0.5px;
      opacity: 0.9;
    }
  </style>
</head>

<body>

  <div class="logo-wrap" tabindex="0">
    <div class="intro_logo">
      <img src="./intro_logo/intro_logo.png" alt="">
    </div>

    <svg id="logoSvg" viewBox="0 0 1000 260" aria-label="VINYST Logo">
      <text
        id="logoText"
        x="50%"
        y="25%"
        dominant-baseline="middle"
        text-anchor="middle"
      >
        VINYST
      </text>
    </svg>

    
    <div class="guide-text">
      클릭하거나 Enter 키를 누르면 시작합니다
    </div>
  </div>

<script>
  const wrap = document.querySelector('.logo-wrap');
  const text = document.getElementById('logoText');
  const TARGET_URL = "<%= ctxPath %>/index.lp";


  // stroke 길이 계산
  const len = text.getComputedTextLength();
  text.style.strokeDasharray = len;
  text.style.strokeDashoffset = len;

  // CSS 변수 값 읽기
  const css = getComputedStyle(document.documentElement);
  const drawTime   = parseFloat(css.getPropertyValue('--draw-time')) * 1000;
  const fillDelay  = parseFloat(css.getPropertyValue('--fill-delay')) * 1000;
  const fillTime   = parseFloat(css.getPropertyValue('--fill-time')) * 1000;

  const TEXT_DONE_TIME = Math.max(drawTime, fillDelay + fillTime);
  const AFTER_DELAY = 0;

  let moved = false; // ✅ 중복 이동 방지

  function moveNow() {
    if (moved) return;
    moved = true;
    wrap.classList.add('zoom');

    setTimeout(() => {
      location.href = TARGET_URL;
    }, 800);
  }

  // 자동 이동
  window.addEventListener('load', () => {
    setTimeout(moveNow, TEXT_DONE_TIME + AFTER_DELAY);
  });

  // ✅ 클릭 시 즉시 이동
  wrap.addEventListener('click', moveNow);

  // ✅ 엔터키 누르면 즉시 이동
  document.addEventListener('keydown', (e) => {
    if (e.key === 'Enter') {
      moveNow();
    }
  });
</script>
</body>
</html>

    