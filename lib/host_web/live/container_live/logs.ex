defmodule HostWeb.ContainerLive.Logs do
  require Logger
  use HostWeb, :live_view

  alias Host.Containers
  alias Host.Containers.Container

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket, layout: false}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    container = Containers.get_container!(id)

    {:noreply,
     socket
     |> assign(:page_title, page_title(container))
     |> assign(:container, container)
     |> assign(:uuid, Ecto.UUID.generate())}
  end

  defp page_title(%Container{name: name}), do: "#{name} Terminal"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen p-4 box-border flex bg-black">
      <div
        id="terminal-emulator-container"
        data-container-id={@container.id}
        data-topic={@uuid}
        data-type="logs"
        phx-hook="TerminalHook"
        class="bg-black flex w-full"
      >
      </div>
    </div>
    """
  end
end
