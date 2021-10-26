Rails.application.routes.draw do
  devise_for :professionals, controllers: {
    sessions: 'professionals/sessions',
    registrations: 'professionals/registrations'
  }
  devise_for :users, controllers: {
    sessions: 'users/sessions',
    registrations: 'users/registrations'
  }

  authenticated :user do
    root to: 'home#dashboard', as: :authenticated_user_root
  end

  authenticated :professional do
    root to: 'home#dashboard', as: :authenticated_professional_root
  end

  root to: 'home#index'
  
  resources :projects, only: [:index, :show, :new, :create, :edit, :update] do
    get '/search', to: 'projects#search', on: :collection

    resources :proposals, only: [:new, :create] #, shallow: true
  end

  resources :proposals, only: [:destroy] do
    get '/cancel', to: 'proposals#cancel'
  end

  # TODO: mover para nested de projects
  get '/my_projects', to: 'projects#my_projects'

  # get '/proposals/:id/cancel_proposal', to: 'proposals#cancel',
  #   as: :cancel_proposal
end
