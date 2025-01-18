Rails.application.routes.draw do
  root to: "homes#top"

  get 'books/search', to: 'books#search', as: 'search_books'

  get "book_authors/create"
  get "book_authors/destroy"
  get "authors/index"
  get "authors/show"
  get "authors/new"
  get "authors/create"  


  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations"
  }

  devise_scope :user do
    get "/users/sign_out" => "devise/sessions#destroy"
  end

  resources :users, only: [ :show ]
  resources :tasks
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/* (remember to link manifest in application.html.erb)
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker

  # Defines the root path route ("/")
  # root "posts#index"
end
