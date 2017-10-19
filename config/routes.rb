Rails.application.routes.draw do
  devise_for :admins
  devise_for :drivers
  devise_for :users
  apipie
  post "reset_trip", :to => "application#reset_trip"
  get "test_google_api", :to => "application#test_google_api"
  get "map/driver_available", :to => "map#driver_available"

  resources :drivers do
    member do
      patch 'activate'
      patch 'deactivate'
      patch 'available'
    end
  end
  resources :users do
    member do
      patch 'activate'
      patch 'deactivate'
    end
  end

  resources :trips
  # root :to => "apipie/apipies#index"
  root :to => "map#map"
  get "map", :to => "map#map"
  namespace :api do
		namespace :v1 do
  		post "driver", :to => "session#signup_driver"
  		post "client", :to => "session#signup_client"
  		post "driver/login", :to => "session#login_driver"
  		post "client/login", :to => "session#login_client"
  		post "logout", :to => "session#logout"
      post "trip", :to => "trip#request_trip"
      post "trip/:trip_id/accept", :to => "trip#accept_trip"
      post "trip/:trip_id/reject", :to => "trip#reject_trip"
      post "trip/:trip_id/cancel", :to => "trip#cancel_trip"
      post "trip/:trip_id/complete", :to => "trip#complete_trip"
      put "driver", :to => "session#update_driver"
      put "client", :to => "session#update_client_location"
      patch "driver", :to => "session#update_driver"
  	end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
