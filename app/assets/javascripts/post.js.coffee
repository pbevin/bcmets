window.setupPost = ->
  $(".quote").click ->
    newBody = $("#article_qt").val() + "\n\n" + $("#quoted").text()
    $("#article_qt").val newBody
    $("#quoted").empty()
    $(".quote").hide()
    $(".quote_lecture").show()
    return false

  $(".email input").blur ->
    $(this).mailcheck
      suggested: (_, suggestion) ->
        $('.email_suggestion .address').text(suggestion.full)
        $('.email_suggestion').show()
      empty: ->
        $('.email_suggestion').fadeOut()

  $(".email .address").click ->
    $(".email input").val($(this).text())
    $(".email_suggestion").fadeOut()
