defmodule Engage.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      Engage.Repo,
      # Start the Telemetry supervisor
      EngageWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: Engage.PubSub},
      # Start the Endpoint (http/https)
      EngageWeb.Endpoint
      # Start a worker by calling: Engage.Worker.start_link(arg)
      # {Engage.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Engage.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EngageWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
