defmodule HostWeb.VirtualMachineLive.Show do
  use HostWeb, :live_view

  alias Host.VirtualMachines

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"id" => id}, _, socket) do
    {:noreply,
     socket
     |> assign(:page_title, page_title(socket.assigns.live_action))
     |> assign(:virtual_machine, VirtualMachines.get_virtual_machine!(id))}
  end

  defp page_title(:show), do: "Show Virtual machine"
  defp page_title(:edit), do: "Edit Virtual machine"
end
