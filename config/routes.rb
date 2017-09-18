Rails.application.routes.draw do
  devise_for :drivers
  devise_for :users
  apipie

  namespace :api do
		namespace :v1 do
  		post "driver", :to => "session#signup_driver"
  		post "client", :to => "session#signup_client"
  		post "driver/login", :to => "session#login_driver"
  		post "client/login", :to => "session#login_client"
  		post "logout", :to => "session#logout"
  	end
  end
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
