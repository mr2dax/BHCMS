Bhcms::Application.routes.draw do

  # for offline caching of resources with local store HTML5
  #match "/application.manifest" => Rails::Offline
  # gallery
  get "uploads/index"

  get "uploads/new"

  get "uploads/create"

  get "uploads/destroy"
  # Sorcery
  get "password_resets/create"

  get "password_resets/edit"

  get "password_resets/update"
  
  # Sorcery
  resources :password_resets
  
  resources :vendors do
    member do
      get :activate
    end
  end

  # other resources
  resources :vendor_sessions

  resources :vendors

  resources :themes

  resources :exported_pages

  resources :templates

  resources :pages

  resources :sites
  
  resources :uploads
  
  resources :assets

  # needed for routing to admin after logging in
  get 'admin' => 'admin#index'
  
  match '/admin/index', :to => 'vendors#edit'
  # for the gallery iframe in manage view
  match '/uploads/index', :to => 'uploads#index'
  match '/uploads/update_desc', :to => 'uploads#update_desc'

  # session control
  get "vendor_sessions/new"
  get "vendor_sessions/create"
  get "vendor_sessions/destroy"
  # pages methods
  match 'page_manage' => 'pages#manage'
  match 'page_new_page' => 'pages#new_page'
  match 'save_page' => 'pages#save_page'
  match 'export_page' => 'pages#export_page'
  match 'destroy' => 'pages#destroy'
  match 'export_all' => 'pages#export_all'
  match 'set_landing' => 'pages#set_landing'
  match 'refresh_pages_list' => 'pages#refresh_pages_list'
  match 'refresh_resources_list' => 'pages#refresh_resources_list'
  # session control
  match 'login' => 'vendor_sessions#new', :as => :login
  match 'logout' => 'vendor_sessions#destroy', :as => :logout

  # The priority is based upon order of creation:
  # first created -> highest priority.

  # Sample of regular route:
  #   match 'products/:id' => 'catalog#view'
  # Keep in mind you can assign values other than :controller and :action

  # Sample of named route:
  #   match 'products/:id/purchase' => 'catalog#purchase', :as => :purchase
  # This route can be invoked with purchase_url(:id => product.id)

  # Sample resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Sample resource route with options:
  #   resources :products do
  #     member do
  #       get 'short'
  #       post 'toggle'
  #     end
  #
  #     collection do
  #       get 'sold'
  #     end
  #   end

  # Sample resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Sample resource route with more complex sub-resources
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', :on => :collection
  #     end
  #   end

  # Sample resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  # You can have the root of your site routed with "root"
  # just remember to delete public/index.html.
  # entry point to the application
  root :to => 'vendors#index'

# See how all your routes lay out with "rake routes"

# This is a legacy wild controller route that's not recommended for RESTful applications.
# Note: This route will make all actions in every controller accessible via GET requests.
# match ':controller(/:action(/:id))(.:format)'
end