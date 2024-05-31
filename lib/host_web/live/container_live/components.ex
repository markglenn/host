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
    <.container_status_icon status={@status} /> <%= String.capitalize(@status) %>
    """
  end

  defp container_status_icon(%{status: "running"} = assigns),
    do: ~H"""
    <.icon name="hero-play" class="text-green-500 w-5 inline-block" />
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
