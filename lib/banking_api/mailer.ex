defmodule BankingApi.Mailer do
  @moduledoc """
  Makes Bamboo Email library available for the App
  """
  use Bamboo.Mailer, otp_app: :banking_api
end
