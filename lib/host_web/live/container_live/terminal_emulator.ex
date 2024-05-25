defmodule HostWeb.ContainerLive.TerminalEmulator do
  use HostWeb, :live_view
  require Logger

  alias Host.Docker.Client
  alias Host.Docker.TtyClient

  alias Phoenix.LiveView.Socket

  @type terminal_type_t :: :log | :tty

  @impl true
  def mount(_params, %{"id" => container_id, "terminal_type" => terminal_type}, socket) do
    if connected?(socket) do
      case start_terminal(container_id, terminal_type) do
        {:ok, pid} ->
          {:ok, assign(socket, terminal: pid)}

        {:error, reason} ->
          Logger.error("Could not start terminal: #{reason}")
          {:ok, assign(socket, error_message: "Could not start terminal")}
      end
    else
      {:ok, socket}
    end
  end

  @spec start_terminal(String.t(), terminal_type_t()) :: {:ok, pid()} | {:error, String.t()}
  defp start_terminal(container_id, :tty) do
    # Start a TTY terminal

    with {:ok, id} <- Client.create_tty_instance(container_id),
         {:ok, pid} <- TtyClient.start_link(id) do
      {:ok, pid}
    else
      {:error, _} -> {:error, "Could not connect to docker socket"}
    end
  end

  defp start_terminal(container_id, :log) do
    # Start a log terminal
    Client.watch_logs(container_id)
  end

  @impl true
  def handle_event("terminal-read", %{"data" => content}, socket) do
    TtyClient.send_data(socket.assigns.terminal, content)

    {:noreply, socket}
  end

  @impl true
  def handle_info({:terminal_write, data}, socket) do
    valid_data = String.replace(data, ~r/[^\x01-\x7E]/, "")

    {:noreply, push_event(socket, "terminal-write", %{content: valid_data})}
  end

  @impl true
  def handle_info({:terminal_closed}, socket) do
    {:noreply, push_event(socket, "close-window", %{})}
  end

  @impl true
  @spec render(Socket.assigns()) :: Phoenix.LiveView.Rendered.t()
  def render(assigns) do
    ~H"""
    <div id="terminal-emulator-container" phx-hook="TerminalHook" class="bg-black flex w-full"></div>
    """
  end
end
