function pluralize(count, singular, plural) {
  if (!plural) {
    plural = singular + "s";
  }

  if (count == 1) {
    return "1 " + singular;
  } else {
    return "" + count + " " + plural;
  }
}

var VALID_EMAIL = new RegExp(/\b[A-Z0-9._%+-]+@[A-Z0-9.-]+\.[A-Z]{2,}\b/i);

function validEmail(email) {
  return email.match(VALID_EMAIL);
}
