Rails.application.routes.draw do

  root to: "homes#top"

  devise_for :users, controllers: {
    sessions: "users/sessions",
    registrations: "users/registrations",
    passwords: "users/passwords"
  }
  get "users" => redirect("/users/sign_up")

  get "books/search_by_title_author", to: "books#search", as: "search_books" # 検索フォーム表示 (indexアクション)
  post "books/search_by_title_author", to: "books#search_by_title_author", as: "books_search_by_title_author"
  get "books/:isbn", to: "books#show", as: "book"

  get "regions", to: "regions#index", as: "regions"
  get "regions/:pref_name", to: "regions#show", as: "region"
  get "/libraries/autocomplete", to: "libraries#autocomplete"

  get "libraries", to: "libraries#index", as: "library_index"
  get "library_detail", to: "libraries#show", as: "library_detail"

  resources :library_settings, only: [ :index, :create, :destroy ] do
  end


  get 'libraries/nearby', to: 'libraries#nearby'


  resources :want_to_read_books, only: [:index, :create, :destroy], param: :isbn
  resources :already_read_books, only: [:index, :create, :destroy], param: :isbn
end

