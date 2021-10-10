Rails.application.routes.draw do
  devise_for :professionals
  devise_for :users

  authenticated :user do
    root to: 'home#dashboard', as: :authenticated_root
  end

  # authenticated :professionals do
  #   root to: 'home#dashboard', as: :authenticated_root
  # end

  root to: 'home#index'
  
  resources :projects, only: [:show, :new, :create, :edit, :update] # do
    # get 'my_projects', on: :collection
  # end
end
