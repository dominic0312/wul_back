require 'sidekiq/web'
WooulAdmin::Application.routes.draw do

  mount Sidekiq::Web, at: "/sidekiq"
  resources :guarantee_companies

  resources :fixed_deposits do
    collection do
      get :settle
      get :publish
      get :finish
      get :refund
      get :switchdisplay
      get :payprofit
    end
  end

  resources :month_deposits do
    collection do
      get :settle
      get :publish
      get :finish
      get :refund
      get :switchdisplay
      get :payprofit
      get :payprincipal
    end
  end



   resources :products do
    collection do
      get '/settle/:product_type',  to: 'products#settle', as: :settle
      get '/:product_type/:id/publish', to: 'products#publish', as: :publish
      get '/:product_type/:id/exp_account', to: 'products#exp_account', as: :exp_account
      get '/:product_type/:id/switchdisplay', to: 'products#switchdisplay', as: :switchdisplay
      get '/:product_type/:id/finish', to: 'products#finish', as: :finish
      get '/:product_type/:id/payprofit', to: 'products#payprofit', as: :payprofit
      get '/:product_type/:id/payprincipal', to: 'products#payprincipal', as: :payprincipal
      get '/:product_type/:id/refund', to: 'products#refund', as: :refund
      get '/:product_type/:id/edit', to: 'products#edit', as: :edit
      get '/:product_type', to: 'products#index', as: :index
      get '/:product_type/new', to: 'products#new', as: :new
      get '/:product_type/:id', to: 'products#show', as: :show

      post '/:product_type', to: 'products#create', as: :create
      post '/:product_type/:id', to: 'products#update', as: :update
      get :refund
      get :payprofit
      get :payprincipal
    end
   end


  namespace :accounting do
    # get '/', to: 'console#index'
    # get '/console/overview'
    post '/account/execute_cmd',{format: :json}
  end



  resources :photos

  resources :personal_reviews

  resources :personal_assets

  resources :user_companies

  resources :personal_finances

  resources :personal_credits

  resources :user_infos

  resources :roles

  devise_for :employees
	root to: 'homes#index'

	resources :homes
	resources :invests
	resources :notices
  resources :account_records
  resources :account_operations

	resources :users
	resources :employees
end
