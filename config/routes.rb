Rails.application.routes.draw do
  devise_for :users #, controllers: { registrations: "registrations" }
  root to: 'home#index'
  resources :projects do
    get 'my_projects', on: :collection
  end
end
