defmodule HostWeb.ContainerLive.Index do
  use HostWeb, :live_view

  import HostWeb.ContainerLive.Components

  alias Host.Containers

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :containers, Containers.list_containers())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Containers")
    |> assign(:container, nil)
  end

  @impl true
  def handle_info({HostWeb.ContainerLive.FormComponent, {:saved, container}}, socket) do
    {:noreply, stream_insert(socket, :containers, container)}
  end
end
