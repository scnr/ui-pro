Rails.application.routes.draw do
    root to: 'sites#index'

    resources :sites do
        post  :invite_user, on: :member
        put   :verify,      on: :member
    end

    devise_for :users
    resources :users
end
