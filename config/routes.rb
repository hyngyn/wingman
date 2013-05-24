Wingman::Application.routes.draw do
  post '/search' => 'pages#search'

  root :to => 'pages#home'

end