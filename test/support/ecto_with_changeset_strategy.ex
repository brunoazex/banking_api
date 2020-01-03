# test/support/ecto_with_changeset_strategy.ex

defmodule BankingApi.EctoWithChangesetStrategy do
  @moduledoc """
  Introduces changeset mechanism into ExMachina
  """
  use ExMachina.Strategy, function_name: :insert

  def handle_insert(record, %{repo: repo}) do
    changeset = apply(record.__struct__, :changeset, [struct(record.__struct__), Map.from_struct(record)])
    if not changeset.valid?, do: raise "Invalid changeset: #{changeset.errors |> inspect}"
    changeset |> repo.insert!()
  end
end
