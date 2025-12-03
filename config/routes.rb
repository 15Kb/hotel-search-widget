Rails.application.routes.draw do
  get 'home/index'

  root 'home#index'

  # API routes
  namespace :api do
    get 'hotels/cities', to: 'hotels#cities'
    post 'hotels/search', to: 'hotels#search'
  end

  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html
end
