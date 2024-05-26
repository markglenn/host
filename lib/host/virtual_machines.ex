defmodule Host.VirtualMachines do
  @moduledoc """
  The VirtualMachines context.
  """

  import Ecto.Query, warn: false
  alias Host.Repo

  alias Host.VirtualMachines.VirtualMachine

  @doc """
  Returns the list of virtual_machines.

  ## Examples

      iex> list_virtual_machines()
      [%VirtualMachine{}, ...]

  """
  def list_virtual_machines do
    []
  end

  @doc """
  Gets a single virtual_machine.

  Raises `Ecto.NoResultsError` if the Virtual machine does not exist.

  ## Examples

      iex> get_virtual_machine!(123)
      %VirtualMachine{}

      iex> get_virtual_machine!(456)
      ** (Ecto.NoResultsError)

  """
  def get_virtual_machine!(id), do: Repo.get!(VirtualMachine, id)

  @doc """
  Creates a virtual_machine.

  ## Examples

      iex> create_virtual_machine(%{field: value})
      {:ok, %VirtualMachine{}}

      iex> create_virtual_machine(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_virtual_machine(attrs \\ %{}) do
    %VirtualMachine{}
    |> VirtualMachine.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a virtual_machine.

  ## Examples

      iex> update_virtual_machine(virtual_machine, %{field: new_value})
      {:ok, %VirtualMachine{}}

      iex> update_virtual_machine(virtual_machine, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_virtual_machine(%VirtualMachine{} = virtual_machine, attrs) do
    virtual_machine
    |> VirtualMachine.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a virtual_machine.

  ## Examples

      iex> delete_virtual_machine(virtual_machine)
      {:ok, %VirtualMachine{}}

      iex> delete_virtual_machine(virtual_machine)
      {:error, %Ecto.Changeset{}}

  """
  def delete_virtual_machine(%VirtualMachine{} = virtual_machine) do
    Repo.delete(virtual_machine)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking virtual_machine changes.

  ## Examples

      iex> change_virtual_machine(virtual_machine)
      %Ecto.Changeset{data: %VirtualMachine{}}

  """
  def change_virtual_machine(%VirtualMachine{} = virtual_machine, attrs \\ %{}) do
    VirtualMachine.changeset(virtual_machine, attrs)
  end
end
