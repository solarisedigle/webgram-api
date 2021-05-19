Rails.application.routes.draw do
  root 'test#index'
  get 'api/v1/p_headers', to: 'test#p_headers'
  post 'api/v1/login', to: 'user#login'
  post 'api/v1/getMe', to: 'user#get_me'
  get 'api/v1/user', to: 'user#print_all'
  get 'api/v1/user/profile/:username', to: 'user#profile'
  post 'api/v1/user', to: 'user#register'
  get 'api/v1/user/:id/getRelation', to: 'user#get_relation'
  post 'api/v1/user/:id/subscribe', to: 'user#subscribe'
  delete 'api/v1/user/:id/subscribe', to: 'user#unsubscribe'
  delete 'api/v1/user/:id', to: 'user#kick'
  get 'api/v1/user/:id', to: 'user#view'
  post 'api/telegramHandler/oTh3r_$lD3', to: 'telegram#index'
  get 'api/v1/posts', to: 'post#get_by'
  post 'api/v1/post', to: 'post#create'
  get 'api/v1/getCategories', to: 'general#categories_list'
  post 'api/v1/category', to: 'general#create_category'
  delete 'api/v1/category/:id', to: 'general#delete_category'
  delete 'api/v1/tag/:id', to: 'general#delete_tag'
  delete 'api/v1/tag/:tag_id/post/:post_id', to: 'general#delete_tag_post'
  post 'api/v1/post/:id/like', to: 'post#like'
  delete 'api/v1/post/:id/like', to: 'post#dislike'
  get 'api/v1/post/:id/like', to: 'post#check_like'
  post 'api/v1/post/:id/comment', to: 'comment#create'
  delete 'api/v1/post/:id', to: 'post#delete'
  post 'api/v1/comment/:id/reply', to: 'comment#reply'
  delete 'api/v1/comment/:id', to: 'comment#delete'
  get 'api/v1/comment/:id', to: 'comment#get_me'
  get 'api/v1/tagsAutocomplete/', to: 'general#complete_tags'
  get 'api/v1/tagsAutocomplete/:tag', to: 'general#complete_tags'
end
