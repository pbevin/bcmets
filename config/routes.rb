Bcmets::Application.routes.draw do
  resources :feeds
  resources :links
  resources :donations do
      collection do
    get :stats
    end
  end

  get 'login' => 'user_sessions#new', :as => :login
  post 'login' => 'user_sessions#create', :as => :login
  match 'logout' => 'user_sessions#destroy', :as => :logout
  match '/register/:activation_code' => 'activations#new', :as => :register
  match '/activate/:id' => 'activations#create', :as => :activate
  match '/password_reset/:activation_code' => 'activations#reset_password', :as => :reset_password
  match '/user_profile/:id' => 'users#profile', :as => :user_profile
  match '/users/password' => 'users#password', :as => :forgot_password
  match '/users/edit_email' => 'users#edit_email', :as => :edit_email
  match '/users/edit_email' => 'users#edit_email', :as => :save_email
  match '/users/edit_password' => 'users#edit_password', :as => :edit_password
  match '/users/edit_password' => 'users#edit_password', :as => :save_password
  match '/users/unsubscribe' => 'users#unsubscribe', :as => :unsubscribe
  resources :user_sessions
  resources :users
  resources :articles
  match 'donations.html' => 'pages#donate'
  match 'saved' => 'articles#saved'
  match 'archive/article/:id' => 'archive#article', :as => :bookmarked_article, :constraints => 'id(?-mix:\d+)'
  match '/archive/:year/:month/date' => 'archive#month_by_date', :as => :archive_month_by_date, :year => /\d{4}/
  match '/article/:id/reply/' => 'articles#reply', :as => :article_reply
  match '/articles/:id/set_saved' => 'articles#set_saved', :as => :article_set_saved
  match '/articles/:id/is_saved' => 'articles#is_saved', :as => :article_is_saved
  match 'archive/:year/:month' => 'archive#month', :as => :archive_month, :year => /\d{4}/
  match 'post.pl' => 'articles#new'
  match 'post' => 'articles#new', :as => :post
  match 'donate' => 'pages#donate'
  match 'blogs' => 'feed_entries#index', :as => :feed_entries
  match '/' => 'archive#index', :as => :root
  match '/:controller(/:action(/:id))'
end
