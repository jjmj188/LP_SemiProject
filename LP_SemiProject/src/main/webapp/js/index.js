// 무한 스크롤 카루셀 (스크린샷 느낌)
    const track = document.getElementById('track');

    // track의 첫 세트를 복제해서 끝에 붙여, 끊김 없이 루프
    const original = Array.from(track.children);
    original.forEach(node => track.appendChild(node.cloneNode(true)));

    let x = 0;
    const speed = 0.45; // 값↑ = 더 빠름

    // 루프 기준(원본 세트 폭)
    function getLoopWidth(){
      let w = 0;
      for (let i = 0; i < original.length; i++){
        w += original[i].getBoundingClientRect().width;
        // gap(22px)
        w += 22;
      }
      return w;
    }

    let loopW = 0;
    const updateLoopWidth = () => { loopW = getLoopWidth(); };
    window.addEventListener('resize', updateLoopWidth);
    updateLoopWidth();

    // 살짝 hover하면 멈추는 UX (원본 사이트들이 자주 쓰는 패턴)
    let paused = false;
    track.addEventListener('mouseenter', () => paused = true);
    track.addEventListener('mouseleave', () => paused = false);

    function tick(){
      if (!paused){
        x -= speed;
        // 원본 세트만큼 이동하면 되감기
        if (-x >= loopW) x = 0;
        track.style.transform = `translateX(${x}px)`;
      }
      requestAnimationFrame(tick);
    }
    tick();

    // 마우스 휠로도 가로 이동(스크롤 안내 문구랑 어울리게)
    const rail = document.querySelector('.rail');
    rail.addEventListener('wheel', (e) => {
      // 트랙 위에서 세로 스크롤을 가로로 전환
      if (Math.abs(e.deltaY) > Math.abs(e.deltaX)) {
        e.preventDefault();
        x -= e.deltaY * 0.9;
        // 범위 정리
        if (x > 0) x = 0;
        if (-x >= loopW) x = 0;
        track.style.transform = `translateX(${x}px)`;
      }
    }, { passive:false });

	// Show all Records 버튼 → 상품 리스트로 스크롤
document.getElementById("btnShowAll").addEventListener("click", () => {
  const target = document.getElementById("product-list");
  if (!target) return;

  // sticky topbar 높이만큼 보정
  const topbar = document.querySelector(".topbar");
  const headerH = topbar ? topbar.offsetHeight : 0;

  const y = target.getBoundingClientRect().top + window.pageYOffset - headerH - 12;
  window.scrollTo({ top: y, behavior: "smooth" });

});



//취향추천
  const scrollLeft = document.querySelector(".scroll-left");
  const scrollRight = document.querySelector(".scroll-right");
  const heroDiv = document.querySelector(".hero-img");
  const sectionContainer = document.querySelector("section");
  const bodyContainer = document.querySelector("body");
  const emblemDiv = document.querySelector(".emblem");
  const albumTitleSpan = document.querySelector(".album-title");
  const texts = document.querySelectorAll(".text");
  const albumNum = document.querySelector(".album-num"); // 없어도 OK
  const quickLink = document.querySelector("#quickLink");

  const albums = Array.from(document.querySelectorAll("#lpData .lp-item")).map((el) => ({
    album: el.dataset.album,
    emblem: el.dataset.emblem,
    "accent-color": el.dataset.accent || "#9a9a9a",
    url: el.dataset.img,
    link: el.dataset.link
  }));

  if (albums.length === 0) {
    console.warn("lp-item 데이터가 없습니다. #lpData 안에 .lp-item을 추가하세요.");
  }

  scrollLeft.addEventListener("click", () => handleClickScroll(-1));
  scrollRight.addEventListener("click", () => handleClickScroll(1));

  heroDiv.addEventListener("animationend", () => {
    heroDiv.classList.remove("album-transition");
    document.addEventListener("keydown", handleKeyScroll);
    scrollLeft.disabled = false;
    scrollRight.disabled = false;
    scrollLeft.classList.remove("key-press-hover-left");
    scrollRight.classList.remove("key-press-hover-right");
    for (const text of texts) text.classList.add("show-texts");
  });

  const handleClickScroll = (val) => {
    if (albums.length === 0) return;
    if (index + val >= 0 && index + val < albums.length) updateDisplay((index += val));
  };

  const handleKeyScroll = (e) => {
    if (albums.length === 0) return;
    if (e.key === "ArrowLeft") {
      scrollLeft.classList.add("key-press-hover-left");
      handleClickScroll(-1);
    }
    if (e.key === "ArrowRight") {
      scrollRight.classList.add("key-press-hover-right");
      handleClickScroll(1);
    }
  };

  let index = 0;

  const updateDisplay = (index) => {
    const DELIMITER = "";
    const album = albums[index];

    for (const text of texts) text.classList.remove("show-texts");
    emblemDiv.innerHTML = "";
    scrollLeft.disabled = true;
    scrollRight.disabled = true;
    document.removeEventListener("keydown", handleKeyScroll);

    sectionContainer.id = `hero-${album.album.toLowerCase().replaceAll(" ", "-")}`;
    bodyContainer.style.background = "";
    heroDiv.style.backgroundImage = `url(${album.url})`;
    albumTitleSpan.textContent = album.album;
    quickLink.href = album.link;

    // ✅ 번호(span.album-num)를 삭제했으면 여기서 그냥 스킵
    if (albumNum) {
      const number = albums.length - index;
      albumNum.innerText = number >= 10 ? number + "." : `0${number}.`;
      albumNum.style.color = album["accent-color"];
    }

    if (index === 0) scrollLeft.classList.add("hide-arrow");
    else scrollLeft.classList.remove("hide-arrow");

    if (index === albums.length - 1) scrollRight.classList.add("hide-arrow");
    else scrollRight.classList.remove("hide-arrow");

    createEmblem(album.emblem, DELIMITER[0] || undefined).forEach((node) => emblemDiv.append(node));
    heroDiv.classList.add("album-transition");
  };

  const createEmblem = (string, delimiter = "•") => {
    const spans = [];
    string = (string || "").trim().replaceAll(" ", delimiter) + delimiter;

    const numChars = string.length || 1;
    const degVal = 90 / (numChars / 4);

    string.split("").forEach((char, idx) => {
      const span = document.createElement("span");
      span.innerText = char;
      span.style.transform = `rotate(${180 - degVal * idx}deg)`;
      if (char === delimiter) span.style.color = albums[index]["accent-color"];
      spans.push(span);
    });

    return spans;
  };

  // 초기화 (앨범 있으면 첫 번째 보여주기)
  if (albums.length > 0) updateDisplay(index);
  
  
  
