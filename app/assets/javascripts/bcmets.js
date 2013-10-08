function initStar() {
  var status = $("#header .status");
  status.hide();
  $("#star a").click( function() {
    var star = $("#star a.star");
    var message = $("#star a.save_this");
    var spinner = star.parent().find("img");
    var ajaxDone = function() { spinner.hide(); star.show(); setText(); };
    var setText = function() { message.text(star.hasClass("selected") ? "Message saved" : "Save this message"); }
    var saved = false;

    star.toggleClass("selected");
    if (star.hasClass("selected")) {
      saved = true;
    }
    star.hide(); spinner.show();
    $.ajax({
      type: "POST",
      url: document.location.href + "/set_saved",
      data: { saved: saved },
      success: ajaxDone,
      error: ajaxDone
    });
  } );

  function setStatus(message) {
    if (message != "") {
      status.text(message).fadeIn();
    } else {
      status.fadeOut();
    }
  }
  function clearStatus() {
    setStatus("");
  }
  clearStatus();

  $("#star a").hover(function() {
    var star = $(this);
    if (star.hasClass("selected")) {
      setStatus("Article is in your saved list. Click again to remove it.");
    } else {
      setStatus("Click the star to add this article to your Saved Articles list.");
    }
  }, clearStatus);
}
