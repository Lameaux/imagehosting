Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#browse'

  get '/upload', to: 'home#upload'
  post '/upload', to: 'upload#create'

  get '/browse(/:sort/:type/:size)',
      to: 'home#browse',
      defaults: { sort: 'popular', type: 'any', size: 'any' },
      constraints: { sort: /popular|new/, type: /any|png|gif|jpg/, size: /any|icon|medium|large/ }

  get '/user/:username(/images)', to: 'home#user_images'
  get '/user/:username/albums', to: 'home#user_albums'

  get '/my(/images)', to: 'home#my_images'
  get '/my/albums', to: 'home#my_albums'

  get '/terms', to: 'home#terms'
  get '/rss', to: 'home#rss'
  get '/sitemap.xml', to: 'home#sitemap'

  get '/login', to: 'user#login'
  post '/login', to: 'user#login_post'
  get '/logout', to: 'user#logout'

  get '/login-facebook', to: 'user#login_facebook'
  get '/register', to: 'user#register'
  post '/register', to: 'user#register_post'

  get '/reset-password', to: 'user#reset_password'
  post '/reset-password', to: 'user#reset_password_post'

  get '/reset-password/:reset_code', to: 'user#reset_password_form', constraints: { reset_code: /[0-9a-zA-Z]+/ }
  put '/reset-password/:reset_code', to: 'user#reset_password_form_put', constraints: { reset_code: /[0-9a-zA-Z]+/ }

  get '/reset-password-sent', to: 'user#reset_password_sent'
  get '/change-password', to: 'user#change_password'
  put '/change-password', to: 'user#change_password_put'
  get '/password-changed', to: 'user#password_changed'
  get '/confirm-email', to: 'user#confirm_email'
  get '/confirm-email/:activation_code', to: 'user#confirm_email_ok', constraints: { activation_code: /[0-9a-zA-Z]+/ }

  get '/a/:id(/:slug)', to: 'album#show', constraints: { id: /[0-9a-zA-Z]+/ }
  get '/album/:id', to: 'album#show', constraints: { id: /[0-9a-zA-Z]+/ }
  put '/album/:id', to: 'album#edit', constraints: { id: /[0-9a-zA-Z]+/ }
  delete '/album/:id', to: 'album#delete', constraints: { id: /[0-9a-zA-Z]+/ }

  get '/:id(/:slug)', to: 'image#show', constraints: { id: /[0-9a-zA-Z]+/ }
  put '/:id', to: 'image#edit', constraints: { id: /[0-9a-zA-Z]+/ }
  delete '/:id', to: 'image#delete', constraints: { id: /[0-9a-zA-Z]+/ }

  post '/:id/tags', to: 'image#add_tag', constraints: { id: /[0-9a-zA-Z]+/ }
  put '/:id/tags', to: 'image#delete_tag', constraints: { id: /[0-9a-zA-Z]+/ }

  post '/:id/likes', to: 'image#add_like', constraints: { id: /[0-9a-zA-Z]+/ }
  put '/:id/likes', to: 'image#delete_like', constraints: { id: /[0-9a-zA-Z]+/ }

  match '*unmatched_route', :to => 'application#raise_not_found!', :via => :all

end
