# lib/router.ex

defmodule BankingApiWeb.Router do
  use BankingApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  pipeline :authenticated do
    plug BankingApiWeb.Auth.Pipeline
  end

  scope "/api", BankingApiWeb do
    pipe_through :api
    resources "/signup", RegistrationController, only: [:create]
    resources "/signin", SessionController, only: [:create]
  end

  scope "/api", BankingApiWeb do
    pipe_through [:api, :authenticated]
    delete "/signout", SessionController, :delete
    get "/statements", BankingController, :index
    post "/withdraw", BankingController, :withdraw
    post "/transfer", BankingController, :transfer
    get "/backoffice/volume", BackOfficeController, :index
  end
end
