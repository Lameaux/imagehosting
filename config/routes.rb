Rails.application.routes.draw do
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html

  root 'home#index'
  post 'upload', to: 'upload#create'

  get ':id', to: 'image#show', constraints: { id: /[0-9a-zA-Z]+/ }

end
