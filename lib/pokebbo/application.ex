defmodule Pokebbo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      PokebboWeb.Telemetry,
      Pokebbo.Repo,
      {DNSCluster, query: Application.get_env(:pokebbo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Pokebbo.PubSub},
      # Start a worker by calling: Pokebbo.Worker.start_link(arg)
      # {Pokebbo.Worker, arg},
      # Start to serve requests, typically the last entry
      PokebboWeb.Endpoint,
      Pokebbo.Rooms.RoomSupervisor,
      Pokebbo.Rooms.Registry,
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Pokebbo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    PokebboWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
