defmodule Host.Containers.PortBinding do
  defstruct [:host_ip, :host_port, :protocol, :container_port]

  @type t :: %__MODULE__{
          host_ip: String.t(),
          host_port: String.t(),
          container_port: String.t(),
          protocol: :udp | :tcp
        }

  @spec new({binary(), [map(), ...]} | map()) :: t()
  def new({container_port, [%{"HostIp" => host_ip, "HostPort" => host_port}]})
      when is_binary(container_port) do
    [container_port, protocol] = String.split(container_port, "/")

    %__MODULE__{
      host_ip: host_ip,
      host_port: host_port,
      container_port: container_port,
      protocol: String.to_existing_atom(protocol)
    }
  end

  def new(%{
        "IP" => host_ip,
        "PrivatePort" => container_port,
        "PublicPort" => host_port,
        "Type" => protocol
      }) do
    %__MODULE__{
      host_ip: host_ip,
      host_port: host_port,
      container_port: container_port,
      protocol: String.to_existing_atom(protocol)
    }
  end

  def new(%{"PrivatePort" => container_port, "Type" => protocol}) do
    %__MODULE__{
      container_port: container_port,
      protocol: String.to_existing_atom(protocol)
    }
  end
end
