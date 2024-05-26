defmodule Host.VirtualMachinesTest do
  use Host.DataCase

  alias Host.VirtualMachines

  describe "virtual_machines" do
    alias Host.VirtualMachines.VirtualMachine

    import Host.VirtualMachinesFixtures

    @invalid_attrs %{name: nil}

    test "list_virtual_machines/0 returns all virtual_machines" do
      virtual_machine = virtual_machine_fixture()
      assert VirtualMachines.list_virtual_machines() == [virtual_machine]
    end

    test "get_virtual_machine!/1 returns the virtual_machine with given id" do
      virtual_machine = virtual_machine_fixture()
      assert VirtualMachines.get_virtual_machine!(virtual_machine.id) == virtual_machine
    end

    test "create_virtual_machine/1 with valid data creates a virtual_machine" do
      valid_attrs = %{name: "some name"}

      assert {:ok, %VirtualMachine{} = virtual_machine} = VirtualMachines.create_virtual_machine(valid_attrs)
      assert virtual_machine.name == "some name"
    end

    test "create_virtual_machine/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = VirtualMachines.create_virtual_machine(@invalid_attrs)
    end

    test "update_virtual_machine/2 with valid data updates the virtual_machine" do
      virtual_machine = virtual_machine_fixture()
      update_attrs = %{name: "some updated name"}

      assert {:ok, %VirtualMachine{} = virtual_machine} = VirtualMachines.update_virtual_machine(virtual_machine, update_attrs)
      assert virtual_machine.name == "some updated name"
    end

    test "update_virtual_machine/2 with invalid data returns error changeset" do
      virtual_machine = virtual_machine_fixture()
      assert {:error, %Ecto.Changeset{}} = VirtualMachines.update_virtual_machine(virtual_machine, @invalid_attrs)
      assert virtual_machine == VirtualMachines.get_virtual_machine!(virtual_machine.id)
    end

    test "delete_virtual_machine/1 deletes the virtual_machine" do
      virtual_machine = virtual_machine_fixture()
      assert {:ok, %VirtualMachine{}} = VirtualMachines.delete_virtual_machine(virtual_machine)
      assert_raise Ecto.NoResultsError, fn -> VirtualMachines.get_virtual_machine!(virtual_machine.id) end
    end

    test "change_virtual_machine/1 returns a virtual_machine changeset" do
      virtual_machine = virtual_machine_fixture()
      assert %Ecto.Changeset{} = VirtualMachines.change_virtual_machine(virtual_machine)
    end
  end
end
