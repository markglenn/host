defmodule HostWeb.ContainerLive.Components do
  use Phoenix.LiveComponent

  attr :ports, :list, required: true, doc: "The list of ports to display."

  def port_quick_view(assigns) do
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
end
