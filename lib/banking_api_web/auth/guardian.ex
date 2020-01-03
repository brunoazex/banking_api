# lib/banking_api_web/auth/guardian.ex

defmodule BankingApiWeb.Auth.Guardian do
  @moduledoc """
  Acts as authentication gatekeeper
  """
  use Guardian, otp_app: :banking_api

  alias BankingApi.Accounts

  def subject_for_token(account, _claims) do
    {:ok, to_string(account.id)}
  end

  def resource_from_claims(claims) do
    id = claims["sub"]
    Accounts.get_by_id(id)
  end

  def authenticate(account_number, password) do
    with {:ok, account} <- Accounts.get_by_number(account_number) do
      case validate_password(password, account.password_hash) do
        true ->
          create_token(account)
        false ->
          {:error, :unauthorized}
      end
    end
  end

  defp validate_password(password, password_hash) do
    Bcrypt.verify_pass(password, password_hash)
  end

  defp create_token(account) do
    {:ok, token, _claims} = encode_and_sign(account)
    {:ok, account, token}
  end
end
