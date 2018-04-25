Rails.application.routes.draw do
  resources :urls do
    post :update_engs, on: :member
  end

  put 'bulk_update', to: 'urls#bulk_update', as: :bulk_update 
  # For details on the DSL available within this file, see http://guides.rubyonrails.org/routing.html
end
