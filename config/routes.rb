DeskToolbelt::Application.routes.draw do
  scope 'migrations', as: 'migrations' do
    match 'desk' => 'migrations#desk'
    match 'zendesk' => 'migrations#zendesk'
    match 'select' => 'migrations#select'
    match 'mapping' => 'migrations#mapping'
    match 'finish' => 'migrations#finish'
    root to: redirect("/migrations/desk")
  end

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
