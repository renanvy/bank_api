defmodule BankApi.Repo do
  use Ecto.Repo,
    otp_app: :bank_api,
    adapter: Ecto.Adapters.Postgres

  @doc """
  Um pequeno wrapper em torno de `Repo.transaction/2'.

  Confirma a transaction se a lambda retornar `:ok` ou `{:ok, result}`, revertendo-a
  se a lambda retornar `:error` ou `{:error, reason}`. Em ambos os casos, a função
  retorna o resultado da lambda.
  """
  @spec transact((() -> any()), keyword()) :: {:ok, any()} | {:error, any()}
  def transact(fun, opts \\ []) do
    transaction(
      fn ->
        case fun.() do
          {:ok, value} -> value
          :ok -> :transaction_commited
          {:error, reason} -> rollback(reason)
          :error -> rollback(:transaction_rollback_error)
        end
      end,
      opts
    )
  end
end
