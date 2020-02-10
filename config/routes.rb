Tally::Engine.routes.draw do

  get "/days/:type/:id", to: "days#index", as: :recordable_days
  resources :days, only: :index

  get "/keys/:type/:id", to: "keys#index", as: :recordable_keys
  resources :keys, only: :index

  get "/records/:type/:id", to: "records#index", as: :recordable_records
  resources :records, only: :index

end
