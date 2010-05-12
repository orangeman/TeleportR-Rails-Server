# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_teleporter_session',
  :secret      => 'edd7e406925d18433470ba29fd00593743c90eb495be72b3c31b3e1724e6e22718e121f12ae0a086ff438dcf41efb3454f1de009b52488aa27c09ac2a5ef64fa'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
