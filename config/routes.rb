Rails.application.routes.draw do

    root to: 'dashboard#index'

    resources :sites do
        ScanResults::SCAN_RESULT_SITE_ACTIONS.each do |action|
            get action, on: :member
        end

        resources :site_roles, as: 'roles', path: 'roles' do
            post  :import, on: :collection
            get   :copy,   on: :member
        end

        resources :scans do
            ScanResults::SCAN_RESULT_SCAN_ACTIONS.each do |action|
                get action, on: :member
            end

            get :preview_schedule, on: :collection
            get :preview_schedule, on: :member

            patch :pause,      on: :member
            patch :resume,     on: :member
            patch :abort,      on: :member
            patch :suspend,    on: :member
            patch :restore,    on: :member

            post  :repeat,     on: :member

            resources :revisions, only: [:show, :destroy] do
                ScanResults::SCAN_RESULT_REVISION_ACTIONS.each do |action|
                    get action, on: :member
                end

                put :revert_configuration, on: :member

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
