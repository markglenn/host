defmodule Host.VirtualMachines.VirtualMachine do
  use Ecto.Schema
  import Ecto.Changeset

  schema "virtual_machines" do
    field :name, :string

    timestamps(type: :utc_datetime)
  end

  @doc false
  def changeset(virtual_machine, attrs) do
    virtual_machine
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
