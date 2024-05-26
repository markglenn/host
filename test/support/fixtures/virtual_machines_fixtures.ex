defmodule Host.VirtualMachinesFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Host.VirtualMachines` context.
  """

  @doc """
  Generate a virtual_machine.
  """
  def virtual_machine_fixture(attrs \\ %{}) do
    {:ok, virtual_machine} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Host.VirtualMachines.create_virtual_machine()

    virtual_machine
  end
end
