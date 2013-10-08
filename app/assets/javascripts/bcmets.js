function initStar() {
  var tooltip = $("#header .tooltip");
  var star = $("#star a.star");
  var message = $("#star a.save_this");
  var spinner = star.parent().find("img");
  var ajaxDone = function() { spinner.hide(); star.show(); setText(); };
  var setText = function() { message.text(star.hasClass("selected") ? "Message saved" : "Save this message"); }

  tooltip.hide();

  $("#star a").click( function() {
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

  $.getJSON(document.location.href + "/is_saved", function(response) {
    star.toggleClass("selected", response.saved);
    ajaxDone();
  });


  function setTooltip(message) {
    if (message != "") {
      tooltip.text(message).fadeIn();
    } else {
      tooltip.fadeOut();
    }
  }
  function clearTooltip() {
    setTooltip("");
  }
  clearTooltip();

  $("#star a").hover(function() {
    var star = $(this);
    if (star.hasClass("selected")) {
      setTooltip("Article is in your saved list. Click again to remove it.");
    } else {
      setTooltip("Click the star to add this article to your Saved Articles list.");
    }
  }, clearTooltip);
}
