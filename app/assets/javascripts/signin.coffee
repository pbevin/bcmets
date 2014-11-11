window.signinForm = ->
  haveEmail    = $('#user_session_email')
    .textValueStream()
    .map(Validation.emailFormat)
  havePassword = $('#user_session_password')
    .textValueStream()
    .map(Validation.nonEmpty)

  validForm = haveEmail.and(havePassword)

  validForm.not().assign $('button.submit'), 'attr', 'disabled'
