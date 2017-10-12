defmodule Cooky.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    import Supervisor.Spec

    # Define workers and child supervisors to be supervised
    children = [
      # Start the Ecto repository
      supervisor(Cooky.Repo, []),
      # Start the endpoint when the application starts
      supervisor(CookyWeb.Endpoint, []),
      worker(Cooking.Chef, [])
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Cooky.Supervisor]
    {:ok, pid} = Supervisor.start_link(children, opts)

    Cooking.Chef.register_status_callback(
      &CookyWeb.CookingChannel.broadcast_status!/1
    )

    {:ok, pid}
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    CookyWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
