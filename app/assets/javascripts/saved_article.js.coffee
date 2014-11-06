window.initStar = (articleId, token) ->

  setText = ->
    $("#star").toggleClass "anon", currentlySaved is null
    star.toggleClass "selected", (if currentlySaved then true else false)
    message.text (if currentlySaved then "Message saved" else "Save this message")

  setTooltip = (message) ->
    if message is ""
      tooltip.fadeOut()
    else
      tooltip.text(message).fadeIn()

  tooltip = $("#header .tooltip")
  star = $("#star a.star")
  message = $("#star a.save_this")
  spinner = star.parent().find("img")
  currentlySaved = star.hasClass("selected")

  tooltip.hide()

  $("#star a").click ->
    star.hide()
    spinner.show()
    $.ajax
      type: "POST"
      url: "/articles/" + articleId + "/set_saved"
      data:
        saved: not currentlySaved
        authenticity_token: token
    .done (resp) ->
      currentlySaved = resp.saved
      setText()
      return
    .always ->
      spinner.hide()
      star.show()

  $.getJSON "/articles/#{articleId}/is_saved", (response) ->
    currentlySaved = response.saved
    setText()

  setTooltip ""

  hoverOn = ->
    if star.hasClass("selected")
      setTooltip "Article is in your saved list. Click again to remove it."
    else
      setTooltip "Click the star to add this article to your Saved Articles list."

  hoverOff = -> setTooltip ""

  $("#star a").hover hoverOn, hoverOff
