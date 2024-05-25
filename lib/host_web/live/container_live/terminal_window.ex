defmodule HostWeb.ContainerLive.TerminalWindow do
  require Logger
  use HostWeb, :live_view

  alias Host.Containers
  alias Host.Containers.Container
  alias HostWeb.ContainerLive.TerminalEmulator

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
     |> assign(:container, container)}
  end

  defp page_title(%Container{name: name}), do: "#{name} Terminal"

  @impl true
  def render(assigns) do
    ~H"""
    <div class="h-screen p-4 box-border flex">
      <%= live_render(@socket, TerminalEmulator,
        id: "terminal",
        session: %{"id" => @container.id, "terminal_type" => :tty},
        container: {:div, class: "w-full bg-black flex p-4 rounded-md"}
      ) %>
    </div>
    """
  end
end
