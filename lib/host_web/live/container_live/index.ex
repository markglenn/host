defmodule HostWeb.ContainerLive.Index do
  use HostWeb, :live_view

  import HostWeb.ContainerLive.Components

  alias Host.Containers
  alias Host.Docker.Workers
  alias Phoenix.PubSub

  require Logger

  @impl true
  def mount(_params, _session, socket) do
    if connected?(socket) do
      PubSub.subscribe(Host.PubSub, "containers:status")
    end

    {:ok, assign(socket, :containers, Containers.list_containers())}
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
  def handle_event("restart", %{"id" => id}, socket) do
    {:ok, _} =
      Supervisor.start_link([{Workers.RestartContainerWorker, id}], strategy: :one_for_one)

    {:noreply, socket}
  end

  def handle_event("stop", %{"id" => id}, socket) do
    {:ok, _} = Supervisor.start_link([{Workers.StopContainerWorker, id}], strategy: :one_for_one)
    {:noreply, socket}
  end

  def handle_event("start", %{"id" => id}, socket) do
    {:ok, _} = Supervisor.start_link([{Workers.StartContainerWorker, id}], strategy: :one_for_one)
    {:noreply, socket}
  end

  @impl true
  def handle_info({HostWeb.ContainerLive.FormComponent, {:saved, container}}, socket) do
    {:noreply, stream_insert(socket, :containers, container)}
  end

  def handle_info({:container_status_update, {container_id, status}}, socket) do
    containers =
      socket.assigns.containers
      |> Enum.map(fn container ->
        if container.id == container_id do
          %{container | status: to_string(status)}
        else
          container
        end
      end)

    {:noreply, assign(socket, :containers, containers)}
  end
end
