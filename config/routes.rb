Bcmets::Application.routes.draw do
  resources :feeds
  resources :links
  resources :donations do
      collection do
    get :stats
    end
  end

  get 'login' => 'user_sessions#new', as: :login
  post 'login' => 'user_sessions#create'
  match 'logout' => 'user_sessions#destroy', as: :logout, via: [:get, :post]
  match '/register/:activation_code' => 'activations#new', as: :register, via: [:get, :post]
  match '/activate/:id' => 'activations#create', as: :activate, via: [:get, :post]
  match '/password_reset/:activation_code' => 'activations#reset_password', as: :reset_password, via: [:get, :post]
  match '/user_profile/:id' => 'users#profile', as: :user_profile, via: [:get, :post]
  match '/users/password' => 'users#password', as: :forgot_password, via: [:get, :post]
  match '/users/edit_email' => 'users#edit_email', as: :edit_email, via: [:get, :post]
  match '/users/edit_email' => 'users#edit_email', as: :save_email, via: [:get, :post]
  match '/users/edit_password' => 'users#edit_password', as: :edit_password, via: [:get, :post]
  match '/users/edit_password' => 'users#edit_password', as: :save_password, via: [:get, :post]
  match '/users/unsubscribe' => 'users#unsubscribe', as: :unsubscribe, via: [:get, :post]
  resources :user_sessions
  resources :users
  resources :articles
  match 'donations.html' => 'pages#donate', via: [:get, :post]
  match 'saved' => 'articles#saved', via: [:get, :post]
  match 'archive/article/:id' => 'archive#article', as: :bookmarked_article, constraints: 'id(?-mix:\d+)', via: [:get, :post]
  match '/archive/:year/:month/date' => 'archive#month_by_date', as: :archive_month_by_date, year: /\d{4}/, via: [:get, :post]
  match '/article/:id/reply/' => 'articles#reply', as: :article_reply, via: [:get, :post]
  match '/articles/:id/set_saved' => 'articles#set_saved', as: :article_set_saved, via: [:get, :post]
  match '/articles/:id/is_saved' => 'articles#is_saved', as: :article_is_saved, via: [:get, :post]
  get 'archive/:year/:month' => 'archive#month', as: :archive_month, year: /\d{4}/
  get 'post.pl' => 'articles#new'
  get 'post' => 'articles#new', as: :post
  get 'donate' => 'pages#donate'
  get 'blogs' => 'feed_entries#index', as: :feed_entries
  get '/' => 'archive#index', as: :root
  match '/:controller(/:action(/:id))', via: [:get, :post]
end
