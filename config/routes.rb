A2Mk2::Application.routes.draw do
  get "home/index"

  get "room/view"

  get "room/new"

  post "room/process_new"

  get "room/edit"

  put "room/process_edit"

  get "room/delete"

  get "room/process_delete"

  get "booking/view"

  get "booking/new"

  post "booking/process_new"

  get "booking/edit"

  put "booking/process_edit"

  get "booking/delete"

  get "booking/process_delete"

  get "user/login"

  post "user/process_login"

  get "user/edit"

  put "user/process_edit"

  get "user/new"

  post "user/process_new"

  get "user/account"

  get "user/process_logout"

  get "user/view"

  get "user/delete"

  get "user/process_delete"

  get "user/password"

  post "user/process_password"

  get "user/reset"

  post "user/process_reset"

  root :to => "home#index"

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
  # root :to => 'welcome#index'

  # See how all your routes lay out with "rake routes"

  # This is a legacy wild controller route that's not recommended for RESTful applications.
  # Note: This route will make all actions in every controller accessible via GET requests.
  # match ':controller(/:action(/:id))(.:format)'
end
