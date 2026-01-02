document.addEventListener("DOMContentLoaded", function () {

  let index = 0;

  const track = document.querySelector(".carousel-track");
  const items = document.querySelectorAll(".carousel-track img");

  if (!track || items.length === 0) return;

  // ⭐ 실제 이미지 너비 계산 (margin 포함)
  const itemWidth = items[0].getBoundingClientRect().width + 20;

  const maxIndex = items.length - 3; // 한 화면에 3장 보일 때

  document.querySelector(".next").addEventListener("click", () => {
    if (index < maxIndex) {
      index++;
      track.style.transform = `translateX(-${index * itemWidth}px)`;
    }
  });

  document.querySelector(".prev").addEventListener("click", () => {
    if (index > 0) {
      index--;
      track.style.transform = `translateX(-${index * itemWidth}px)`;
    }
  });
});

