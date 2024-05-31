defmodule Host.Docker.Workers.RestartContainerWorker do
  use Task
  alias Phoenix.PubSub

  alias Host.Docker.Client

  require Logger

  def start_link(container_id) do
    Task.start_link(__MODULE__, :run, [container_id])
  end

  def run(container_id) do
    Logger.info("Restarting container: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :restarting}}
    )

    case Client.restart_container(container_id) do
      {:ok, _} ->
        Logger.info("Container restarted: #{container_id}")

        PubSub.broadcast(
          Host.PubSub,
          "containers:status",
          {:container_status_update, {container_id, :running}}
        )

      {:error, _} ->
        Logger.error("Failed to restart container: #{container_id}")

        PubSub.broadcast(
          Host.PubSub,
          "containers:status",
          {:container_status_update, {container_id, :stopped}}
        )
    end
  end
end
