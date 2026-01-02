$(function () {
 
  $("#requestSelect").on("change", function () {
    const val = $(this).val();
    $("#requestText").val(val === "직접 입력" ? "" : val);
  });
});