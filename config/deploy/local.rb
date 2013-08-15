set :stage, :local

# Set the app server host and port
role :app, %w{kualiadm@localhost:2222}

# Deploy from the develop branch
set :branch, 'development'