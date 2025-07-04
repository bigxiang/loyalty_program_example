Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  namespace :api do
    namespace :v1 do
      resources :points, only: [] do
        collection do
          post :earn
        end
      end

      resources :rewards, only: [] do
        collection do
          post :issue
        end
      end
    end
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

  # Handle unmatched routes
  match "*unmatched", to: "application#route_not_found", via: :all
end
