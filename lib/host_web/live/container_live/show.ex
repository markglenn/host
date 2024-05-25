defmodule HostWeb.ContainerLive.Show do
  require Logger
  use HostWeb, :live_view

  alias Host.Containers

  import HostWeb.ContainerLive.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:container, Containers.get_container!(id))}
  end

  defp page_title(:show), do: "Show Container"
end
