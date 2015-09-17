Rails.application.routes.draw do

    root to: 'dashboard#index'

    resources :sites do
        get :issues,   on: :member
        get :coverage, on: :member
        get :reviews,  on: :member

        resources :site_roles, as: 'roles', path: 'roles' do
            post  :import, on: :collection
            get   :copy,   on: :member
        end

        resources :scans do
            get :issues,   on: :member
            get :coverage, on: :member
            get :reviews,  on: :member

            get :preview_schedule, on: :collection
            get :preview_schedule, on: :member

            patch :pause,      on: :member
            patch :resume,     on: :member
            patch :abort,      on: :member
            patch :suspend,    on: :member
            patch :restore,    on: :member

            post  :repeat,     on: :member

            resources :revisions, only: [:show, :destroy] do
                get :live,     on: :member
                get :issues,   on: :member
                get :coverage, on: :member
                get :reviews,  on: :member
                get :health,   on: :member

                resources :issues, only: [:show, :update]
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
