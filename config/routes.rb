# frozen_string_literal: true

Rails.application.routes.draw do
  namespace :v1 do
    resources :requests, controller: :packages, only: [:index, :show, :create], param: :bag_id
    post "/requests/:bag_id/complete", controller: :queue_items, action: :create

    resources :packages, only: [:index, :show], param: :bag_id
    get "/packages/:bag_id/download", controller: :packages, action: :send_package
    get "/packages/:bag_id/events", controller: :events, action: :index
    get "/packages/:bag_id/:file", controller: :packages, action: :sendfile, file: /.*/

    resources :events, only: [:index]

    resources :bags, only: [:index, :show], controller: :packages, param: :bag_id
    get "/bags/:bag_id/events", controller: :events, action: :index

    # We foresee the need for destroy; currently out of scope.
    resources :queue_items, only: [:index, :show], path: :queue do
      get "status", on: :collection
    end

    resources :audits, only: [:index, :create, :show]
  end

  namespace :v2 do
    resources :artifacts, only: [:index, :show, :create]
    resources :deposits, only: [:index, :show, :create]
    post "/artifacts/:artifact_id/revisions", controller: :deposits, action: :create
    post "/deposits/:id/complete", controller: :deposits, action: :ready
  end

  get "/login", to: "login#new", as: "login"
  post "/login", to: "login#create", as: "login_as"
  match "/logout", to: "login#destroy", as: "logout", via: [:get, :post]

  get "*path", to: "application#fallback_index_html", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end

  root to: "application#fallback_index_html", constraints: ->(request) do
    !request.xhr? && request.format.html?
  end
end
