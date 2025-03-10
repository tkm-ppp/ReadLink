Rails.application.routes.draw do
  root to: "homes#top"

  devise_for :users, controllers: {
  sessions: "users/sessions",
  registrations: "users/registrations"
  }
  get "users" => redirect("/users/sign_up")

  get "libraries/settings", to: "libraries#settings", as: "library_settings"

  get "books/search_by_title_author", to: "books#search", as: "search_books" # 検索フォーム表示 (indexアクション)
  post "books/search_by_title_author", to: "books#search_by_title_author", as: "books_search_by_title_author"
  get "books/:isbn", to: "books#show", as: "book"

  get "regions", to: "regions#index", as: "regions"
  get "regions/:pref_name", to: "regions#show", as: "region"
  get "/libraries/autocomplete", to: "libraries#autocomplete"

  get "libraries", to: "libraries#index", as: "library_index"
  get "library_detail", to: "libraries#show", as: "library_detail"

  get "libraries/settings", to: "libraries#settings", as: "library_setting"
  post "libraries/settings", to: "libraries#create"
  delete "libraries/settings", to: "libraries#destroy"
end
