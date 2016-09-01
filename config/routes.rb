Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#browse'

  get '/upload', to: 'home#upload'
  post '/upload', to: 'upload#create'

  get '/browse(/:sort/:type/:size)', to: 'home#browse', defaults: { sort: 'popular', type: 'all', size: 'all' }

  get '/search', to: 'home#search'
  get '/my', to: 'home#my'

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
  get '/change-password', to: 'user#change_password'
  get '/confirm-email', to: 'user#confirm_email'

  get '/:id', to: 'image#show', constraints: { id: /[0-9a-zA-Z]+/ }
  put '/:id', to: 'image#edit', constraints: { id: /[0-9a-zA-Z]+/ }
  delete '/:id', to: 'image#delete', constraints: { id: /[0-9a-zA-Z]+/ }

  get '/album/:id', to: 'album#show', constraints: { id: /[0-9a-zA-Z]+/ }
  put '/album/:id', to: 'album#edit', constraints: { id: /[0-9a-zA-Z]+/ }
  delete '/album/:id', to: 'album#delete', constraints: { id: /[0-9a-zA-Z]+/ }

end
