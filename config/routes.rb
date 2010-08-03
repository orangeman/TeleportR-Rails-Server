ActionController::Routing::Routes.draw do |map|
  map.resources :plugins

 
  map.root :controller => "countries"
  
  map.resources :countries do |country|
  	country.resources :states do |state|
  		state.resources :states do |state|
  			state.resources :cities do |city|
		  		city.resources :places
  			end
  		end
  		state.resources :cities do |city|
  			city.resources :places
  		end
  		state.connect "streets", :controller => 'places', :action => 'streets'
  		state.connect "stations.:format", :controller => 'places', :action => 'stations'
  	end
  	country.resources :cities do |city|
  		city.resources :places
  	end
  end
 
  map.resources :states
  map.resources :cities

  map.connect "stations/nearby.:format", :controller => 'places', :action => 'nearby'

  map.connect "downloads.:format", :controller => 'downloads', :action => 'index'


  # The priority is based upon order of creation: first created -> highest priority.

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
  # map.root :controller => "welcome"

  # See how all your routes lay out with "rake routes"

  # Install the default routes as the lowest priority.
  # Note: These default routes make all actions in every controller accessible via GET requests. You should
  # consider removing or commenting them out if you're using named routes and resources.
  map.connect ':controller/:action/:id'
  map.connect ':controller/:action/:id.:format'
end
