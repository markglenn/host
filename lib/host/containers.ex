defmodule Host.Containers do
  @moduledoc """
  The Containers context.
  """

  import Ecto.Query, warn: false

  alias Host.Containers.Container
  alias Host.Docker.Client

  @doc """
  Returns the list of containers.

  ## Examples

      iex> list_containers()
      [%Container{}, ...]

  """
  def list_containers do
    {:ok, containers} = Client.list_containers(all: true)
    Enum.map(containers, &Container.new/1)
  end

  def get_container!(id) do
    {:ok, container} = Client.get_container(id)
    Container.new(container)
  end
end
