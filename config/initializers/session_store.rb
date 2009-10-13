# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_tweenion_session',
  :secret      => '849f53810b47c23868b6fde7ec742c3d505dc894e4d01741bd1369b49a39a0ee0dab8176d0648e8eae9d25ab7edd51ef191ccb9654c7467d0e0d42318522fa26'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
