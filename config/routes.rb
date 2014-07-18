Rails.application.routes.draw do
    root to: 'sites#index'

    resources :sites, skip: [:update] do
        post  :invite_user,  on: :member
        get   :verification, on: :member
        put   :verify,       on: :member

        resources :scans
    end

    devise_for :users
    resources :users
    resources :profiles
end
