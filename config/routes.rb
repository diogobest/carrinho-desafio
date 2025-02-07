require 'sidekiq/web'

Rails.application.routes.draw do
  mount Sidekiq::Web => '/sidekiq'
  resources :products
  get "up" => "rails/health#show", as: :rails_health_check

  resource :cart, only: [:show, :create] do
    post "add_items"
    delete ':product_id', to: 'carts#destroy'
  end

  root "rails/health#show"
end
