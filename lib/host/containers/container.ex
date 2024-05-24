defmodule Host.Containers.Container do
  defstruct [
    :id,
    :name,
    :compose_project,
    :image,
    :status,
    :exit_code,
    :ports,
    :raw
  ]

  alias Host.Containers.PortBinding

  @type t :: %__MODULE__{
          id: String.t(),
          name: String.t(),
          compose_project: String.t() | nil,
          image: String.t(),
          status: String.t(),
          exit_code: integer() | nil,
          raw: map(),
          ports: [PortBinding.t()]
        }

  @spec new(map()) :: t()
  def new(
        %{
          "Id" => id,
          "Name" => name,
          "State" => %{"Status" => status},
          "Config" => %{"Image" => image},
          "HostConfig" => %{"PortBindings" => ports}
        } = container
      ) do
    compose_project = get_compose_info(container)
    exit_code = get_in(container, ["State", "ExitCode"])

    %__MODULE__{
      id: id,
      name: String.replace_leading(name, "/", ""),
      compose_project: compose_project,
      image: image,
      status: status,
      exit_code: exit_code,
      ports: Enum.map(ports, &PortBinding.new/1),
      raw: container
    }
  end

  def new(
        %{
          "Id" => id,
          "Names" => [name | _],
          "State" => status,
          "Ports" => ports,
          "Image" => image
        } =
          container
      ) do
    compose_project = get_compose_info(container)

    %__MODULE__{
      id: id,
      name: String.replace_leading(name, "/", ""),
      compose_project: compose_project,
      image: image,
      status: status,
      ports: Enum.map(ports, &PortBinding.new/1),
      raw: container
    }
  end

  defp get_compose_info(container) do
    labels = get_in(container, ["Config", "Labels"]) || get_in(container, ["Labels"])

    Map.get(labels, "com.docker.compose.project")
  end
end
