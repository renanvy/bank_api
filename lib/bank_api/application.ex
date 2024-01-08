defmodule BankApi.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      BankApiWeb.Telemetry,
      BankApi.Repo,
      {DNSCluster, query: Application.get_env(:bank_api, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: BankApi.PubSub},
      # Start a worker by calling: BankApi.Worker.start_link(arg)
      # {BankApi.Worker, arg},
      # Start to serve requests, typically the last entry
      BankApiWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BankApi.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    BankApiWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
