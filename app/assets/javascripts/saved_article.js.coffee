$.fn.initStar = (articleId, initialSaved, token) ->
  tooltip = $("#header .tooltip")
  star = this.find("a.star")
  message = this.find("a.save_this")

  remoteSetSaved = (val) ->
    $.ajax
      type: "POST"
      url: "/articles/#{articleId}/set_saved"
      data:
        saved: val
        authenticity_token: token

  tooltip.hide()
  star.show()

  clicks = this.find("a").asEventStream('click').map (e) ->
    if star.hasClass("selected") then false else true

  optimisticResults = clicks
  realResults = clicks.flatMapLatest (saved) ->
    Bacon.fromPromise remoteSetSaved(saved)
      .map(".saved")

  results = optimisticResults
    .merge(realResults)
    .toProperty(initialSaved)
    .map (saved) ->
      if saved
        saved: true
        message: "Message saved"
        tooltip: "Article is in your saved list. Click again to remove it."
      else
        saved: false
        message: "Save this message"
        tooltip: "Click the star to add this article to your Saved Articles list."

  results.onValue (state) ->
    star.toggleClass("selected", state.saved)
    message.text state.message
    tooltip.text state.tooltip


  hoverTooltip = (hovering) ->
    -> tooltip.toggle(hovering)
  this.find("a").hover hoverTooltip(true), hoverTooltip(false)
