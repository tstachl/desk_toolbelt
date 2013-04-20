DeskToolbelt::Application.routes.draw do
  scope '/migrations', as: 'migrations' do
    match 'desk' => 'migrations#desk'
    match 'zendesk' => 'migrations#zendesk'
    match 'select' => 'migrations#select'
    match 'finish' => 'migrations#finish'
  end
  get 'migrations', to: redirect('/migrations/desk')  
  post 'migrations' => 'migrations#create'
  
  resources :auths do
    get 'change', on: :member
  end
  resources :exports
  resources :translations
  resources :imports

  scope '/auth' do
    get 'login' => 'sessions#new', as: :login
    get 'failure' => 'sessions#failure', as: :login_failure
    get 'logout' => 'sessions#destroy', as: :logout
    match ':provider/callback' => 'auths#create'
  end
  
  root to: 'sessions#index'
end
