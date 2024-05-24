defmodule HostWeb.ContainerLive.Show do
  require Logger
  alias Host.Docker.LogWatcher
  use HostWeb, :live_view

  alias Host.Containers

  import HostWeb.ContainerLive.Components

  @impl true
  def mount(%{"id" => id}, _session, socket) do
    if connected?(socket) do
      LogWatcher.connect(id)
    end

    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:container, Containers.get_container!(id))}
  end

  @impl true
  def handle_info({:docker_log, data}, socket) do
    valid_data = String.replace(data, ~r/[^\x01-\x7E]/, "")
    {:noreply, push_event(socket, "terminal-write", %{content: valid_data})}
  end

  defp page_title(:show), do: "Show Container"
end
