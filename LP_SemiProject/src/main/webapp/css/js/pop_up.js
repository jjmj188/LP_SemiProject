document.addEventListener("DOMContentLoaded", function () {
  const today = new Date().toDateString();

  if (localStorage.getItem("hideJoy") !== today) {
    document.getElementById("popupJoy").style.display = "flex";
  } else if (localStorage.getItem("hideDelivery") !== today) {
    document.getElementById("popupDelivery").style.display = "flex";
  }
});

function closeJoy() {
  const today = new Date().toDateString();
  const hideJoyToday = document.getElementById("hideJoyToday");

  if (hideJoyToday && hideJoyToday.checked) {
    localStorage.setItem("hideJoy", today);
  }

  document.getElementById("popupJoy").style.display = "none";
  document.getElementById("popupDelivery").style.display = "flex";
}

function closeDelivery() {
  const today = new Date().toDateString();
  const hideDeliveryToday = document.getElementById("hideDeliveryToday");

  if (hideDeliveryToday && hideDeliveryToday.checked) {
    localStorage.setItem("hideDelivery", today);
  }

  document.getElementById("popupDelivery").style.display = "none";
}
