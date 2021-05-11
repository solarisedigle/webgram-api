# README

Some usefull commands:

Recreate database:
// Locally
 - rake db:drop db:create db:migrate
// Heroku
 - heroku pg:reset --app --confirm webgram-api
 - heroku run rake db:migrate --app webgram-api

