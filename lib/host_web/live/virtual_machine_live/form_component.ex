defmodule HostWeb.VirtualMachineLive.FormComponent do
  use HostWeb, :live_component

  alias Host.VirtualMachines

  @impl true
  def render(assigns) do
    ~H"""
    <div>
      <.header>
        <%= @title %>
        <:subtitle>Use this form to manage virtual_machine records in your database.</:subtitle>
      </.header>

      <.simple_form
        for={@form}
        id="virtual_machine-form"
        phx-target={@myself}
        phx-change="validate"
        phx-submit="save"
      >
        <.input field={@form[:name]} type="text" label="Name" />
        <:actions>
          <.button phx-disable-with="Saving...">Save Virtual machine</.button>
        </:actions>
      </.simple_form>
    </div>
    """
  end

  @impl true
  def update(%{virtual_machine: virtual_machine} = assigns, socket) do
    changeset = VirtualMachines.change_virtual_machine(virtual_machine)

    {:ok,
     socket
     |> assign(assigns)
     |> assign_form(changeset)}
  end

  @impl true
  def handle_event("validate", %{"virtual_machine" => virtual_machine_params}, socket) do
    changeset =
      socket.assigns.virtual_machine
      |> VirtualMachines.change_virtual_machine(virtual_machine_params)
      |> Map.put(:action, :validate)

    {:noreply, assign_form(socket, changeset)}
  end

  def handle_event("save", %{"virtual_machine" => virtual_machine_params}, socket) do
    save_virtual_machine(socket, socket.assigns.action, virtual_machine_params)
  end

  defp save_virtual_machine(socket, :edit, virtual_machine_params) do
    case VirtualMachines.update_virtual_machine(socket.assigns.virtual_machine, virtual_machine_params) do
      {:ok, virtual_machine} ->
        notify_parent({:saved, virtual_machine})

        {:noreply,
         socket
         |> put_flash(:info, "Virtual machine updated successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp save_virtual_machine(socket, :new, virtual_machine_params) do
    case VirtualMachines.create_virtual_machine(virtual_machine_params) do
      {:ok, virtual_machine} ->
        notify_parent({:saved, virtual_machine})

        {:noreply,
         socket
         |> put_flash(:info, "Virtual machine created successfully")
         |> push_patch(to: socket.assigns.patch)}

      {:error, %Ecto.Changeset{} = changeset} ->
        {:noreply, assign_form(socket, changeset)}
    end
  end

  defp assign_form(socket, %Ecto.Changeset{} = changeset) do
    assign(socket, :form, to_form(changeset))
  end

  defp notify_parent(msg), do: send(self(), {__MODULE__, msg})
end
