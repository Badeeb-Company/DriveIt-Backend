Rails.application.routes.draw do
  devise_for :drivers
  devise_for :users
  apipie
  post "reset_trip", :to => "application#reset_trip"
  get "test_google_api", :to => "application#test_google_api"
  # root :to => "apipie/apipies#index"
  root :to => "map#map"
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
  	end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
