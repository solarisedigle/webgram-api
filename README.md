# README

### Some usefull commands:

##### Recreate database:
###### Locally:
 - rake db:drop db:create db:migrate
###### Heroku:
 - heroku heroku pg:reset --app webgram-api --confirm webgram-api
 - heroku run rake db:migrate --app webgram-api

