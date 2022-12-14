defmodule EmployeeReward.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Ecto repository
      EmployeeReward.Repo,
      # Start the Telemetry supervisor
      EmployeeRewardWeb.Telemetry,
      # Start the PubSub system
      {Phoenix.PubSub, name: EmployeeReward.PubSub},
      # Start the Endpoint (http/https)
      EmployeeRewardWeb.Endpoint,
      # Call the GenServer's start_link/1 function
      EmployeeReward.AutomatedPointsDistribution
      # Start a worker by calling: EmployeeReward.Worker.start_link(arg)
      # {EmployeeReward.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: EmployeeReward.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    EmployeeRewardWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
