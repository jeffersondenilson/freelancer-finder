Rails.application.routes.draw do
  devise_for :professionals
  devise_for :users

  authenticated :user do
    root to: 'home#dashboard', as: :authenticated_user_root
  end

  authenticated :professional do
    root to: 'home#dashboard', as: :authenticated_professional_root
  end

  root to: 'home#index'
  
  resources :projects, only: [:show, :new, :create, :edit, :update]
end
