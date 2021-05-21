# README

## A word spoken is past recalling.
### Some usefull commands:

###### Locally:
 - rake db:drop db:create db:migrate
 - kill $(lsof -t -i:3001)
###### Heroku:
 - heroku pg:reset --app webgram-api --confirm webgram-api
 - heroku run rake db:migrate --app webgram-api

