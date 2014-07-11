Rails.application.routes.draw do
    root to: 'sites#index'

    resources :sites

    devise_for :users
    resources :users
end
