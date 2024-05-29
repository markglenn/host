defmodule HostWeb.TerminalSessionChannel do
  use HostWeb, :channel

  alias Phoenix.PubSub
  alias Host.Docker.Client
  alias Host.Docker.TtyClient

  require Logger

  @impl true
  def join("terminal:shell:" <> topic, %{"container_id" => container_id} = _payload, socket) do
    case start_terminal(container_id, :tty, topic) do
      {:ok, _terminal_id} ->
        {:ok, socket}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end

    {:ok, assign(socket, container_id: container_id, topic: topic)}
  end

  def join("terminal:logs:" <> topic, %{"container_id" => container_id} = _payload, socket) do
    case start_terminal(container_id, :logs, topic) do
      {:ok, _terminal_id} ->
        {:ok, socket}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end

    {:ok, assign(socket, container_id: container_id, topic: topic)}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  # It is also common to receive messages from the client and
  # broadcast to everyone in the current topic (terminal_session:lobby).
  @impl true
  def handle_in("write", %{"data" => data}, socket) do
    PubSub.broadcast!(
      Host.PubSub,
      "terminal:#{socket.assigns.topic}:write",
      {:terminal_write, data}
    )

    {:noreply, socket}
  end

  @impl true
  def handle_info({:terminal_read, data}, socket) do
    broadcast!(socket, "read", %{content: data})
    {:noreply, socket}
  end

  def handle_info(:terminal_closed, socket) do
    broadcast!(socket, "closed", %{})
    {:noreply, socket}
  end

  defp start_terminal(container_id, :tty, topic) do
    # Start a TTY terminal

    with {:ok, id} <- Client.create_tty_instance(container_id),
         {:ok, _pid} <- TtyClient.start_link(id, topic) do
      PubSub.subscribe(Host.PubSub, "terminal:#{topic}:read")
      PubSub.subscribe(Host.PubSub, "terminal:#{topic}:closed")
      {:ok, id}
    else
      {:error, _} -> {:error, "Could not connect to docker socket"}
    end
  end

  defp start_terminal(container_id, :logs, topic) do
    # Start a log watcher
    PubSub.subscribe(Host.PubSub, "terminal:#{topic}:read")
    Client.watch_logs(container_id, topic)
  end
end
