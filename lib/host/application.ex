defmodule Host.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      HostWeb.Telemetry,
      Host.Repo,
      {DNSCluster, query: Application.get_env(:host, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: Host.PubSub},
      # Start the Finch HTTP client for sending emails
      {Finch, name: Host.Finch},
      # Start a worker by calling: Host.Worker.start_link(arg)
      # {Host.Worker, arg},
      {Host.Docker.EventWatcher, "/var/run/docker.sock"},
      # Start to serve requests, typically the last entry
      HostWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Host.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    HostWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
