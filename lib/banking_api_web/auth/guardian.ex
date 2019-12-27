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
    resource = Accounts.get_account!(id)
    {:ok, resource}
  end

  def authenticate(account_number, password) do
    with {:ok, account} <- Accounts.get_account_by_number(account_number) do
      case validate_password(password, account.password_hash) do
        true ->
          create_token(account)
        false ->
          {:error, :unauthorized}
      end
    end
  end

  def after_encode_and_sign(resource, claims, token, _options) do
    with {:ok, _} <- Guardian.DB.after_encode_and_sign(resource, claims["typ"], claims, token) do
      {:ok, token}
    end
  end

  def on_verify(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_verify(claims, token) do
      {:ok, claims}
    end
  end

  def on_refresh({old_token, old_claims}, {new_token, new_claims}, _options) do
    with {:ok, _, _} <- Guardian.DB.on_refresh({old_token, old_claims}, {new_token, new_claims}) do
      {:ok, {old_token, old_claims}, {new_token, new_claims}}
    end
  end

  def on_revoke(claims, token, _options) do
    with {:ok, _} <- Guardian.DB.on_revoke(claims, token) do
      {:ok, claims}
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
