Rails.application.routes.draw do
  root 'test#index'
  get 'api/v1/p_headers', to: 'test#p_headers'
  get 'api/v1/login', to: 'user#login'
  get 'api/v1/user', to: 'user#print_all'
  get 'api/v1/user/new', to: 'user#register'
  get 'api/v1/user/:id', to: 'user#view'
end
