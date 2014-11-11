VALID_EMAIL = new RegExp(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)

window.Validation =
  nonEmpty: (v) -> v.length > 0
  emailFormat: (v) -> v.match VALID_EMAIL

$.fn.textValueStream = ->
  get = => this.val() or ""
  autoFillPoller = Bacon.interval(50).take(10).map(get).filter(Validation.nonEmpty).take 1
  this
    .asEventStream('keyup input')
    .merge(this.asEventStream('propertychange'))
    .merge(this.asEventStream('cut paste').delay(1))
    .merge(autoFillPoller)
    .map(get)
    .skipDuplicates()
    .toProperty this.val()
