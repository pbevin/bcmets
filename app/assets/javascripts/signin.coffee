$.fn.valueStream = ->
  this
    .asEventStream('input')
    .merge(this.asEventStream('propertychange'))
    .merge(this.asEventStream('paste'))
    .map (e) -> e.target.value
    .skipDuplicates()
    .toProperty this.val()

VALID_EMAIL = new RegExp(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i)

window.signinForm = ->
  form = Bacon.combineTemplate({
    email: $('#user_session_email').valueStream(),
    password: $('#user_session_password').valueStream()
  })

  valid = form.map (f) -> !!f.email.match(VALID_EMAIL) and f.password isnt ""

  valid.not().onValue $('button.submit'), 'attr', 'disabled'
