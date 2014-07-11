Rails.application.routes.draw do
  resources :sites

    root to: 'visitors#index'
    devise_for :users
    resources :users
end
