defmodule HostWeb.ContainerLive.Components do
  use Phoenix.LiveComponent
  import HostWeb.CoreComponents

  attr :ports, :list, required: true, doc: "The list of ports to display."

  def container_ports(assigns) do
    ~H"""
    <ul>
      <%= for port_binding <- Enum.take(@ports, 2) do %>
        <li>
          <%= port_binding.container_port %> / <%= port_binding.host_port %>
        </li>
      <% end %>
    </ul>
    """
  end

  attr :status, :string, required: true, doc: "The status of the container."

  def container_status(assigns) do
    ~H"""
    <div class="flex items-center">
      <div class="w-8 h-6 flex-shrink-0">
        <.container_status_icon status={@status} />
      </div>
      <%= String.capitalize(@status) %>
    </div>
    """
  end

  defp container_status_icon(%{status: "running"} = assigns),
    do: ~H"""
    <.icon name="hero-play" class="text-green-500" />
    """

  defp container_status_icon(%{status: status} = assigns)
       when status in ["restarting", "stopping", "starting"],
       do: ~H"""
       <.icon name="hero-arrow-path-mini" class="animate-spin-slow" />
       """

  defp container_status_icon(%{status: "exited"} = assigns),
    do: ~H"""
    <.icon name="hero-x-circle" class="text-red-300" />
    """

  defp container_status_icon(assigns),
    do: ~H""
end
