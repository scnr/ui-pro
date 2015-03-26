Rails.application.routes.draw do
    ActiveAdmin.routes(self)

    root to: 'dashboard#index'

    resources :sites, except: [:update] do
        post  :invite_user,  on: :member
        get   :verification, on: :member
        put   :verify,       on: :member

        resources :scans do
            resources :revisions, only: [:show, :destroy]
        end
    end

    devise_for :users#, skip: :registrations

    resources :profiles do
        get :copy, on: :member
    end

    resources :schedules, only: [:index]

    resources :plans
end
