set :stage, :tst

# Set the app server host and port
role :app, %w{kualiadm@uaz-kf-a05.mosaic.arizona.edu}

# Deploy from the develop branch
set :branch, 'development'