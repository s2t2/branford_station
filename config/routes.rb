Rails.application.routes.draw do

  #resources :feed_checks, :only => [:new]

  get 'hosts' => 'feed_hosts#index', :as => 'hosts'
  get 'hosts/:id' => 'feed_hosts#show', :as => 'host'

  #get 'feeds' => 'feeds#index', :as => 'feeds'
  #get 'feeds/:id' => 'feeds#show', :as => 'feed'

  get 'hosts/:host_id/feeds' => 'hosted_feeds#index', :as => 'hosted_feeds'
  get 'hosts/:host_id/feeds/:feed_id' => 'hosted_feeds#show', :as => 'hosted_feed'
  get 'hosts/:host_id/feeds/:feed_id/latest_version' => 'hosted_feeds#show_latest', :as => 'hosted_feed_latest_version'
  get 'hosts/:host_id/feeds/:feed_id/check' => 'hosted_feeds#check', :as => 'hosted_feed_check'

  get 'hosts/:host_id/feeds/:feed_id/versions' => 'hosted_feed_versions#index', :as => 'hosted_feed_versions'
  get 'hosts/:host_id/feeds/:feed_id/versions/:version_id' => 'hosted_feed_versions#show', :as => 'hosted_feed_version'

  get 'hosts/:host_id/feeds/:feed_id/versions/:version_id/agencies' => 'agency_versions#index', :as => 'agency_versions'
  get 'hosts/:host_id/feeds/:feed_id/versions/:version_id/agencies/:agency_id' => 'agency_versions#show', :as => 'agency_version'

  get 'hosts/:host_id/feeds/:feed_id/versions/:version_id/stops' => 'stop_versions#index', :as => 'stop_versions'
  get 'hosts/:host_id/feeds/:feed_id/versions/:version_id/stops/:stop_id' => 'stop_versions#show', :as => 'stop_version'

  get 'agencies' => 'agencies#index', :as => 'agencies'
  #get 'agencies/:agency_abbreviation/' => 'agencies#show', :as => 'agency'
  get 'agencies/:agency_id/' => 'agencies#show', :as => 'agency'

  #get 'agencies/:agency_abbreviation/stations/:station_abbreviation'  => 'stations#show', :as => 'station'
  #get 'agencies/:agency_id/stations/:station_id'  => 'stations#show', :as => 'station'

  # The priority is based upon order of creation: first created -> highest priority.
  # See how all your routes lay out with "rake routes".

  # You can have the root of your site routed with "root"
  # root 'welcome#index'

  # Example of regular route:
  #   get 'products/:id' => 'catalog#view'

  # Example of named route that can be invoked with purchase_url(id: product.id)
  #   get 'products/:id/purchase' => 'catalog#purchase', as: :purchase

  # Example resource route (maps HTTP verbs to controller actions automatically):
  #   resources :products

  # Example resource route with options:
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

  # Example resource route with sub-resources:
  #   resources :products do
  #     resources :comments, :sales
  #     resource :seller
  #   end

  # Example resource route with more complex sub-resources:
  #   resources :products do
  #     resources :comments
  #     resources :sales do
  #       get 'recent', on: :collection
  #     end
  #   end

  # Example resource route with concerns:
  #   concern :toggleable do
  #     post 'toggle'
  #   end
  #   resources :posts, concerns: :toggleable
  #   resources :photos, concerns: :toggleable

  # Example resource route within a namespace:
  #   namespace :admin do
  #     # Directs /admin/products/* to Admin::ProductsController
  #     # (app/controllers/admin/products_controller.rb)
  #     resources :products
  #   end

  root 'feed_hosts#index'
end
