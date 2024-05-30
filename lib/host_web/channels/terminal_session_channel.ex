defmodule HostWeb.TerminalSessionChannel do
  use HostWeb, :channel

  alias Host.Docker.Client
  alias Host.Docker.TtyClient

  require Logger

  @impl true
  # Handle joining the shell session topic
  def join("terminal:shell:" <> topic, %{"container_id" => container_id} = _payload, socket) do
    case start_terminal(container_id) do
      {:ok, tty_client} ->
        {:ok, assign(socket, tty_client: tty_client, container_id: container_id, topic: topic)}

      {:error, reason} ->
        {:error, %{reason: reason}}
    end
  end

  # Handle joining the logs topic
  def join("terminal:logs:" <> topic, %{"container_id" => container_id} = _payload, socket) do
    Client.watch_logs(container_id)

    {:ok, assign(socket, topic: topic)}
  end

  # Channels can be used in a request/response fashion
  # by sending replies to requests from the client
  @impl true
  def handle_in("ping", payload, socket) do
    {:reply, {:ok, payload}, socket}
  end

  @impl true
  def handle_in("write", %{"data" => data}, %{assigns: %{tty_client: tty_client}} = socket) do
    TtyClient.write(tty_client, data)
    {:noreply, socket}
  end

  # This client is read only (logs)
  def handle_in("write", _, socket), do: {:noreply, socket}

  @impl true
  def handle_info({:terminal_read, data}, socket) do
    broadcast!(socket, "read", %{content: data})
    {:noreply, socket}
  end

  def handle_info(:terminal_closed, socket) do
    broadcast!(socket, "closed", %{})
    {:noreply, socket}
  end

  @impl true
  def handle_cast({:terminal_write, data}, socket) do
    broadcast!(socket, "write", %{content: data})
    {:noreply, socket}
  end

  defp start_terminal(container_id) do
    # Start a TTY terminal

    with {:ok, id} <- Client.create_tty_instance(container_id),
         {:ok, tty_client} <- TtyClient.start_link(id) do
      {:ok, tty_client}
    else
      {:error, _} -> {:error, "Could not connect to docker socket"}
    end
  end
end
