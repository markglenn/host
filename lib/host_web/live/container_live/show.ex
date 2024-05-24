defmodule HostWeb.ContainerLive.Show do
  require Logger
  alias Host.Docker.TtyClient
  use HostWeb, :live_view

  alias Host.Containers
  alias Host.Docker.Client

  import HostWeb.ContainerLive.Components

  @impl true
  def mount(%{"id" => container_id}, _session, socket) do
    if connected?(socket) do
      # Client.watch_logs(container_id)
      {:ok, id} = Client.create_tty_instance(container_id)
      {:ok, pid} = TtyClient.start_link(id)

      {:ok, assign(socket, :tty_client, pid)}
    else
      {:ok, socket}
    end
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:container, Containers.get_container!(id))}
  end

  @impl true
  def handle_event("terminal-read", %{"data" => content}, socket) do
    TtyClient.send_data(socket.assigns.tty_client, content)
    {:noreply, socket}
  end

  @impl true
  def handle_info({:terminal_write, data}, socket) do
    valid_data = String.replace(data, ~r/[^\x01-\x7E]/, "")

    {:noreply, push_event(socket, "terminal-write", %{content: valid_data})}
  end

  defp page_title(:show), do: "Show Container"
end
