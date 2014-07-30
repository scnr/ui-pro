Rails.application.routes.draw do
    root to: 'sites#index'

    resources :sites, except: [:update] do
        post  :invite_user,  on: :member
        get   :verification, on: :member
        put   :verify,       on: :member

        resources :scans do
            resources :revisions, only: [:show, :destroy]
        end
    end

    devise_for :users
    resources :users
    resources :profiles
    resources :schedules, only: [:index]
end
