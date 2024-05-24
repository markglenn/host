defmodule Host.ContainersFixtures do
  @moduledoc """
  This module defines test helpers for creating
  entities via the `Host.Containers` context.
  """

  @doc """
  Generate a container.
  """
  def container_fixture(attrs \\ %{}) do
    {:ok, container} =
      attrs
      |> Enum.into(%{
        name: "some name"
      })
      |> Host.Containers.create_container()

    container
  end
end
