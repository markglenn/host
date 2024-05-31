defmodule Host.Docker.Workers.StartContainerWorker do
  use Task
  alias Phoenix.PubSub

  alias Host.Docker.Client

  require Logger

  def start_link(container_id) do
    Task.start_link(__MODULE__, :run, [container_id])
  end

  def run(container_id) do
    Logger.info("Starting container: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :starting}}
    )

    case Client.start_container(container_id) do
      {:ok, _} ->
        Logger.info("Container started: #{container_id}")

        PubSub.broadcast(
          Host.PubSub,
          "containers:status",
          {:container_status_update, {container_id, :running}}
        )

      {:error, _} ->
        Logger.error("Failed to start container: #{container_id}")

        PubSub.broadcast(
          Host.PubSub,
          "containers:status",
          {:container_status_update, {container_id, :exited}}
        )
    end
  end
end
