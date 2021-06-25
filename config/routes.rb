# frozen_string_literal: true

Spree::Core::Engine.routes.draw do
  resource :mollie, only: [], controller: :mollie do
    post 'update_payment_status', action: :update_payment_status, as: 'mollie_update_payment_status'
    # put 'validate_payment/:order_number', action: :validate_payment, as: 'mollie_validate_payment'
    get 'validate_payment/:order_number', action: :validate_payment, as: 'mollie_validate_payment'
  end

  namespace :api, defaults: { format: 'json' } do
    resources :mollie do
      member do
        get :payment_methods
      end
    end
  end
end