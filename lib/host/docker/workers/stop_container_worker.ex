defmodule Host.Docker.Workers.StopContainerWorker do
  use Task
  alias Phoenix.PubSub

  alias Host.Docker.Client

  require Logger

  def start_link(container_id) do
    Task.start_link(__MODULE__, :run, [container_id])
  end

  def run(container_id) do
    Logger.info("Stopping container: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :stopping}}
    )

    case Client.stop_container(container_id, wait: 10) do
      {:ok, _} ->
        Logger.info("Container stopped: #{container_id}")

        PubSub.broadcast(
          Host.PubSub,
          "containers:status",
          {:container_status_update, {container_id, :exited}}
        )

      {:error, _} ->
        Logger.error("Failed to restart container: #{container_id}")

        PubSub.broadcast(
          Host.PubSub,
          "containers:status",
          {:container_status_update, {container_id, :running}}
        )
    end
  end
end
