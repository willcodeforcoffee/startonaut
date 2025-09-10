Rails.application.routes.draw do
  resources :tags do
    collection do
      get :search
    end
  end
  resources :bookmarks do
    resources :favicon, only: [ :index ], controller: "bookmarks_favicon_proxy"
    collection do
      get :fetch_remote_bookmark
    end
  end
  resources :pages, only: [ :index ]
  resource :session
  resources :passwords, param: :token
  get "home/index"
  get "theme", to: "home#theme", as: :theme if Rails.env.development?
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # Make changes in the HomeController redirect for authentication situations
  root "home#index"
end
