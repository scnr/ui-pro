Rails.application.routes.draw do

    root to: 'dashboard#index'

    resources :sites, except: [:edit] do
        post  :invite_user,  on: :member
        get   :verification, on: :member
        put   :verify,       on: :member

        resources :scans do
            resources :revisions, only: [:show, :destroy]
        end
    end

    devise_for :users, controllers: { registrations: 'registrations' }

    resources :profiles do
        post  :import,  on: :collection
        patch :default, on: :member
        get   :copy,    on: :member
    end

    resources :schedules, only: [:index]

    resources :settings

    resources :user_agents do
        post  :import,  on: :collection
        patch :default, on: :member
        get   :copy,    on: :member
    end
end
