# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_bcmets_session',
  :domain      => 'bcmets.org',
  :secret      => '3f48631d6753e45e4a26ed3096558feabbc20e3216d2944cc297da769ffcc12118f2f034c4d64cccebb83ae6340c27f2ba6da61a651023bda263438cb59deb8b'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
