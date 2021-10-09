Rails.application.routes.draw do
  devise_for :users #, controllers: { registrations: "registrations" }

  root to: 'home#index'
  
  resources :projects, only: [:show, :new, :create, :edit, :update] do
    get 'my_projects', on: :collection
  end
end
