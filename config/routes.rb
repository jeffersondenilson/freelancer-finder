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

    resources :proposals, shallow: true
  end
  # TODO: mover para nested de projects
  get '/my_projects', to: 'projects#my_projects'
end
