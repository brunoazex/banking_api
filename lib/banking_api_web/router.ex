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

  end
end
