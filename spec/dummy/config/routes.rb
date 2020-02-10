Rails.application.routes.draw do

  mount Tally::Engine => "/tally"

  resources :clicks
  resources :impressions

  get "/test/increment", to: "increment#create"

  root to: "base#index"

end
