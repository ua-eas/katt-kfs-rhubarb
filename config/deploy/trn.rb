set :stage, :trn

# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
role :app, "kualiadm@uaz-kf-a06.mosaic.arizona.edu"

#deploy the latest tag
set :branch, `git tag`.split("\n").last