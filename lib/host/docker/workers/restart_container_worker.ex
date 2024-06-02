defmodule Host.Docker.Workers.RestartContainerWorker do
  use Task
  alias Phoenix.PubSub

  alias Host.Docker.Client

  require Logger

  @spec start_link(String.t()) :: {:ok, pid()}
  def start_link(container_id) do
    Task.start_link(__MODULE__, :run, [container_id])
  end

  @spec run(String.t()) :: {:ok, any()} | {:error, any()}
  def run(container_id) do
    Logger.info("Restarting container: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :restarting}}
    )

    Client.restart_container(container_id)
  end
end
