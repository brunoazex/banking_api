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
    scope "/reports" do
      scope "/amounts" do
        get "/interval", AmountsController, :by_interval
        get "/month", AmountsController, :by_month
        get "/year", AmountsController, :by_year
      end
    end
  end
end
