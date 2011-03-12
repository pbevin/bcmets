ActionController::Routing::Routes.draw do |map|
  map.resources :feeds
  map.resources :links
  map.resources :donations, :collection => { :stats => :get }

  map.login "login", :controller => "user_sessions", :action => "new"
  map.logout "logout", :controller => "user_sessions", :action => "destroy"

  map.register '/register/:activation_code', :controller => 'activations', :action => 'new'
  map.activate '/activate/:id', :controller => 'activations', :action => 'create'
  map.reset_password "/password_reset/:activation_code", :controller => 'activations', :action => 'reset_password'

  map.user_profile "/user_profile/:id", :controller => "users", :action => "profile"
  map.forgot_password "/users/password", :controller => "users", :action => "password"
  map.edit_email "/users/edit_email", :controller => "users", :action => "edit_email"
  map.save_email "/users/edit_email", :controller => "users", :action => "edit_email"
  map.edit_password "/users/edit_password", :controller => "users", :action => "edit_password"
  map.save_password "/users/edit_password", :controller => "users", :action => "edit_password"
  map.unsubscribe "/users/unsubscribe", :controller => "users", :action => "unsubscribe"

  map.resources :user_sessions
  map.resources :users
  map.resources :articles

  # The priority is based upon order of creation: first created -> highest priority.
  map.connect 'donations.html',
    :controller => 'pages',
    :action => 'donate'

  map.connect 'archive/:old_year_month/:article_number.html',
    :controller => 'archive',
    :action => 'old_article',
    :requirements => { :old_year_month => /\d{4}-\d{2}/, :article_number => /\d{4}/ }
  map.connect 'archive/:old_year_month',
    :controller => 'archive',
    :action => 'month',
    :requirements => { :old_year_month => /\d{4}-\d{2}/ }
  map.bookmarked_article 'archive/article/:id',
    :controller => 'archive',
    :action => 'article',
    :requirements => { :id => /\d+/ }
  map.archive_month_by_date '/archive/:year/:month/date',
    :controller => 'archive',
    :action => 'month_by_date'
  map.article_reply '/article/:id/reply/',
    :controller => 'articles',
    :action => 'reply'
  map.archive_month 'archive/:year/:month',
    :controller => 'archive',
    :action => 'month'

  map.post 'post',
    :controller => "articles",
    :action => "new"
  map.connect 'post.pl',
    :controller => "articles",
    :action => "new"
  map.connect 'donate',
    :controller => 'pages',
    :action => 'donate'

  map.feed_entries 'blogs',
    :controller => "feed_entries",
    :action => "index"

  # Sample of regular route:
  #   map.connect 'products/:id', :controller => 'catalog', :action => 'view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   map.purchase 'products/:id/purchase', :controller => 'catalog', :action => 'purchase'
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   map.resources :products

  # Sample resource route with options:
  #   map.resources :products, :member => { :short => :get, :toggle => :post }, :collection => { :sold => :get }

  # Sample resource route with sub-resources:
  #   map.resources :products, :has_many => [ :comments, :sales ], :has_one => :seller

  # Sample resource route with more complex sub-resources
  #   map.resources :products do |products|
  #     products.resources :comments
  #     products.resources :sales, :collection => { :recent => :get }
  #   end

  # Sample resource route within a namespace:
  #   map.namespace :admin do |admin|
  #     # Directs /admin/products/* to Admin::ProductsController (app/controllers/admin/products_controller.rb)
  #     admin.resources :products
  #   end

  # You can have the root of your site routed with map.root -- just remember to delete public/index.html.
  map.root :controller => "archive"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing the them or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
