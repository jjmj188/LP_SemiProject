<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>JOY - Happy | LP Shop</title>

    <link rel="stylesheet" href="../css/common/header_except.css">
    <link rel="stylesheet" href="../css/common/footer.css">

    <link rel="stylesheet" href="../css/product/product.css">

    <script src="https://code.jquery.com/jquery-3.7.1.min.js"></script>

    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.7.1/css/all.min.css">
</head>

<body>

    <jsp:include page="./header1.jsp" />

    <main class="product-container">

        <div class="product-image">
            <img src="images/조이.png" alt="JOY - Happy LP">
        </div>

        <div class="product-info">
            <h1>JOY - Happy</h1>
            <p class="price">₩36,000</p>
            <div class="benefit">
                <p class="discount">할인 적용 시 <b>₩32,400</b>(10%)</p>
                <p class="point">적립 포인트 <b>10P</b></p>
            </div>
            <p class="delivery">배송비 <b>2,500원</b></p>

            <div class="quantity">
                <button onclick="changeQty(-1)">−</button>
                <span id="qty">1</span>
                <button onclick="changeQty(1)">+</button>
            </div>

            <div class="wishlist">
                <button type="button" id="wishBtn" onclick="toggleWish()">
                    <i class="fa-solid fa-heart"></i> 찜하기
                </button>
            </div>

            <div class="action-buttons">
                <button type="button" class="buy" onclick="location.href='buy.jsp'">
                    구매하기
                </button>
                <button type="button" class="cart" onclick="location.href='cart.jsp'">
                    장바구니
                </button>
            </div>
        </div>

    </main>

    <section class="product-description">
        <h2>앨범 소개</h2>

        <p class="desc-text">
            JOY의 솔로 앨범 &lt;Happy&gt; LP 입니다.<br><br>

            따뜻한 멜로디와 부드러운 보컬이 어우러진 곡들로 구성되어 있으며,<br>
            일상 속 작은 행복을 느낄 수 있는 감성적인 사운드를 담고 있습니다.<br><br>

            아날로그 특유의 깊은 음질로 JOY의 목소리를 더욱 풍부하게 즐길 수 있으며,<br>
            LP로 소장하기에 충분한 가치를 지닌 앨범입니다.
        </p>
    </section>

    <section class="track-list">
        <h2>TRACK LIST</h2>

        <ol>
            <li>Happy</li>
            <li>Day by Day</li>
            <li>Hello</li>
            <li>Je t'aime</li>
            <li>Good Night</li>
        </ol>
    </section>

    <section class="preview-video">
        <h2>미리 듣기</h2>

        <div class="video">
            <iframe
                src="https://www.youtube.com/embed/uR8Mrt1IpXg"
                title="JOY - Happy"
                allowfullscreen>
            </iframe>
        </div>
    </section>

    <section class="reviews">
        <h2>Reviews</h2>

        <div class="review-item">
            <div class="review-header">
                <span class="user-id">user123</span>

                <div class="review-rating">
                    <i class="fa-solid fa-star" data-value="1"></i>
                    <i class="fa-solid fa-star" data-value="2"></i>
                    <i class="fa-solid fa-star" data-value="3"></i>
                    <i class="fa-solid fa-star" data-value="4"></i>
                    <i class="fa-solid fa-star" data-value="5"></i>
                    <span class="score">4.0 / 5.0</span>
                </div>
            </div>

            <p class="review-text">
                "안녕하세요, 이것은 100자 채우기 테스트용 아무 의미 없는 글자입니다. 웹사이트 디자인이나 문서 작업 시 레이아웃 확인을 위해 주로 사용되며, 의미 없는 라틴어 문장인 '로렘입숨'을 한글로 변환하여 사용하기도 합니다. 다양한 글자 수로 만들 수 있으며, 글자 수를 맞추는 것이 중요합니다. 예를 들어, '나는 오늘 학교에 갔다. 날씨가 매우 맑았다. 친구들과 즐거운 시간을 보냈다. 점심으로 맛있는 김밥을 먹었다. 오후에는 도서관에 갔다. 책을 읽고 집에 돌아왔다. 내일은 주말이다. 기대된다. 신난다. 재미있다. 행복하다. 와우.'와 같이 채울 수 있습니다."
            </p>
        </div>

        <div class="review-more">
            <button type="button">전체보기</button>
        </div>
    </section>

    <jsp:include page="./footer1.jsp" />

    <script>

        let qty = 1;
        function changeQty(num) {
            qty += num;
            if (qty < 1) qty = 1;
            document.getElementById("qty").innerText = qty;
        }

        function toggleWish() {
            // 찜하기 기능 구현
            alert("찜하기 기능은 아직 구현되지 않았습니다.");
        }
    </script>

</body>
</html>