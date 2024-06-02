defmodule Host.Docker.EventWatcher do
  @moduledoc """
  Watches for Docker events and broadcasts them to the PubSub.
  """
  use GenServer

  require Logger
  alias Phoenix.PubSub

  @type state :: %{
          task_pid: pid() | nil
        }

  def start_link(socket \\ nil) do
    GenServer.start_link(__MODULE__, %{socket: socket}, name: __MODULE__)
  end

  @impl true
  def init(%{socket: socket}) do
    {:ok, pid} = do_start_watcher(socket, nil)

    {:ok, %{task_pid: pid}}
  end

  @impl true
  def handle_call({:watch, socket}, _from, %{task_pid: task_pid} = state) do
    {:ok, pid} = do_start_watcher(socket, task_pid)

    {:reply, :ok, %{state | task_pid: pid}}
  end

  def watch(socket \\ "/var/run/docker.sock"), do: GenServer.call(__MODULE__, {:watch, socket})

  @spec do_start_watcher(String.t() | nil, pid() | nil) :: {:ok, pid() | nil}
  defp do_start_watcher(socket, current_task) do
    if current_task do
      Logger.info("Stopping existing event watcher")
      Process.exit(current_task, :kill)
    end

    if is_nil(socket) do
      Logger.info("No socket provided for Docker event watcher")
      {:ok, nil}
    else
      Logger.info("Starting event watcher")

      Task.start(fn ->
        client =
          Tesla.client(
            [Tesla.Middleware.JSON],
            {Host.Docker.FinchAdapter, name: Host.Finch, unix_socket: socket}
          )

        case Tesla.get(client, "http://localhost/events", opts: [adapter: [response: :stream]]) do
          {:ok, env} ->
            env.body
            |> Stream.each(&container_event/1)
            |> Stream.run()

          {:error, reason} ->
            Logger.error("Failed to start event watcher: #{inspect(reason)}")
        end
      end)
    end
  end

  defp container_event(%{"Action" => "stop", "id" => container_id}) do
    Logger.info("Container stopped: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :exited}}
    )
  end

  defp container_event(%{"Action" => "kill", "id" => container_id}) do
    Logger.info("Container stopping: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :stopping}}
    )
  end

  defp container_event(%{"Action" => "start", "id" => container_id} = e) do
    Logger.info("Container started: #{container_id}: #{inspect(e)}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :running}}
    )
  end

  defp container_event(%{"Action" => "die", "id" => container_id}) do
    Logger.info("Container stopped: #{container_id}")

    PubSub.broadcast(
      Host.PubSub,
      "containers:status",
      {:container_status_update, {container_id, :exited}}
    )
  end

  defp container_event(e) do
    Logger.info("Ignored event: #{inspect(e)}")
  end
end
