# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_mysqlkv_session',
  :secret      => '0478283d7541d0b2080f3f5ef03c309b95e77bd80dcfcdc07e53c128bbefc0c7b31a77caeb460b95d0b2ccd79097f4b9f803f85eda0e68b9dc44915d160302da'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
