Rails.application.routes.draw do

  root to: "homes#top"

  devise_for :users, controllers: {
  sessions: 'users/sessions',
  registrations: 'users/registrations',
  }
  get "users" => redirect("/users/sign_up")

  get 'books/search', to: 'books#search', as: 'search_books'
  get 'books/:isbn', to: 'books#show', as: 'book'

  get 'regions', to: 'regions#index', as: 'regions'
  get 'regions/:pref_name', to: 'regions#show', as: 'region'


  get 'library_detail', to: 'libraries#show', as: 'library_detail'

end


