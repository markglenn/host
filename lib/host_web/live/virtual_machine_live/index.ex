defmodule HostWeb.VirtualMachineLive.Index do
  use HostWeb, :live_view

  alias Host.VirtualMachines
  alias Host.VirtualMachines.VirtualMachine

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :virtual_machines, VirtualMachines.list_virtual_machines())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :edit, %{"id" => id}) do
    socket
    |> assign(:page_title, "Edit Virtual machine")
    |> assign(:virtual_machine, VirtualMachines.get_virtual_machine!(id))
  end

  defp apply_action(socket, :new, _params) do
    socket
    |> assign(:page_title, "New Virtual machine")
    |> assign(:virtual_machine, %VirtualMachine{})
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Virtual machines")
    |> assign(:virtual_machine, nil)
  end

  @impl true
  def handle_info({HostWeb.VirtualMachineLive.FormComponent, {:saved, virtual_machine}}, socket) do
    {:noreply, stream_insert(socket, :virtual_machines, virtual_machine)}
  end

  @impl true
  def handle_event("delete", %{"id" => id}, socket) do
    virtual_machine = VirtualMachines.get_virtual_machine!(id)
    {:ok, _} = VirtualMachines.delete_virtual_machine(virtual_machine)

    {:noreply, stream_delete(socket, :virtual_machines, virtual_machine)}
  end
end
