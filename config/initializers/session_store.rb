# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Budgeteer_session',
  :secret      => '3122d49a2fe41f8aa9ffd75e569192a949e89834b3cd964b7c5e1048a8a75ec6579f0f22a2c3c4efc6e265dd28ad8ae2088be8e3c6d4c269886a56868ba2d70e'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
