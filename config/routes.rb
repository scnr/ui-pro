Rails.application.routes.draw do

    root to: 'dashboard#index'

    resources :sites, except: [:edit] do
        resources :schedules, only: [:index]

        resources :site_roles, as: 'roles', path: 'roles' do
            post  :import, on: :collection
            get   :copy,   on: :member
        end

        resources :scans do
            resources :revisions, only: [:show, :destroy] do
                resources :issues, only: [:show, :edit, :update]
            end
        end
    end

    devise_for :users, controllers: { registrations: 'registrations' }

    resources :profiles do
        post  :import,  on: :collection
        patch :default, on: :member
        get   :copy,    on: :member
    end

    resources :settings

    resources :user_agents do
        post  :import,  on: :collection
        patch :default, on: :member
        get   :copy,    on: :member
    end
end
