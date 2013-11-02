function initStar() {
  var tooltip = $("#header .tooltip");
  var star = $("#star a.star");
  var message = $("#star a.save_this");
  var spinner = star.parent().find("img");
  var currentlySaved = star.hasClass("selected");

  tooltip.hide();

  $("#star a").click( function() {
    star.hide(); spinner.show();
    $.ajax({
      type: "POST",
      url: document.location.href + "/set_saved",
      data: { saved: !currentlySaved }
    }).done(function(resp) {
      currentlySaved = resp.saved;
      setText();
    }).always(function() {
      spinner.hide();
      star.show();
    });
  });

  $.getJSON(document.location.href + "/is_saved", function(response) {
    currentlySaved = response.saved
    setText();
  });

  function setText() {
    $('#star').toggleClass("anon", currentlySaved === null);
    star.toggleClass("selected", currentlySaved ? true : false);
    message.text(currentlySaved ? "Message saved" : "Save this message");
  }

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
