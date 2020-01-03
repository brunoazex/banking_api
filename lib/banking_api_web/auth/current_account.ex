# lib/banking_api_web/auth/current_account.ex

defmodule BankingApiWeb.Auth.CurrentAccount do
  @moduledoc """
  Current Logged account handler catcher
  """
  alias BankingApiWeb.Auth.Guardian

  def init(_options) do

  end

  def call(conn, _opts) do
    current_token = Guardian.Plug.current_token(conn)
    case Guardian.resource_from_token(current_token) do
      {:ok, account, _} ->
            Plug.Conn.assign(conn, :current_account, account)
      {:error, _reason} ->
        conn
    end
  end
end
