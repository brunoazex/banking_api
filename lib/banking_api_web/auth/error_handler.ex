# lib/banking_api_web/auth/error_handler.ex

defmodule BankingApiWeb.Auth.ErrorHandler do
  @moduledoc """
  Error handler catcher
  """
  import Plug.Conn

  def auth_error(conn, {type, _reason}, _opts) do
    body = Jason.encode!(%{error: to_string(type)})
    conn
    |> put_resp_content_type("application/json")
    |> send_resp(401, body)
  end
end
