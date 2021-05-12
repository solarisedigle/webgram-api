Rails.application.routes.draw do
  root 'test#index'
  get 'api/v1/p_headers', to: 'test#p_headers'
  post 'api/v1/login', to: 'user#login'
  get 'api/v1/user', to: 'user#print_all'
  post 'api/v1/user/new', to: 'user#register'
  delete 'api/v1/user/:id/oTh3r_$lD3', to: 'user#kick'
  get 'api/v1/user/:id', to: 'user#view'
  post 'api/telegramHandler/oTh3r_$lD3', to: 'telegram#index'
end
