Rails.application.routes.draw do
  resources :sites

    root to: 'sites#index'
    devise_for :users
    resources :users
end
