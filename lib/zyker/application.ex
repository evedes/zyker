defmodule Zyker.Application do
  # See https://elixir.hexdocs.pm/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ZykerWeb.Telemetry,
      Zyker.Repo,
      {DNSCluster, query: Application.get_env(:zyker, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Zyker.PubSub},
      # Start a worker by calling: Zyker.Worker.start_link(arg)
      # {Zyker.Worker, arg},
      # Start to serve requests, typically the last entry
      ZykerWeb.Endpoint
    ]

    # See https://elixir.hexdocs.pm/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Zyker.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ZykerWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
