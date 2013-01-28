DeskToolbelt::Application.routes.draw do
  resources :auths do
    get 'change', on: :member
  end
  resources :exports

  scope '/auth' do
    get 'login' => 'sessions#new', as: :login
    get 'failure' => 'sessions#failure', as: :login_failure
    delete 'logout' => 'sessions#destroy', as: :logout
    match ':provider/callback' => 'auths#create'
  end
  
  root to: 'sessions#index'
end
