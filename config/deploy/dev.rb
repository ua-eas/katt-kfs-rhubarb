set :stage, :dev

# Set the app server host and port
role :app, %w{kualiadm@uaz-kf-a02.mosaic.arizona.edu}

# Deploy from the develop branch
set :branch, 'development'