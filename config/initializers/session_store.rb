# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_Budgeteer_session',
  :secret      => '2142f89652f9bed8f2d3d3be145a3b6ed5e81a73137fe7e4b2eaf8b2e29d0efbf18f60961371ed7e4d3d086c3bfc3989a986f30b62087f13897eb48c05c7a9f0'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
