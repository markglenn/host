defmodule Host.Docker.TtyClient do
  use GenServer

  require Logger

  @spec start_link(any(), any()) :: :ignore | {:error, any()} | {:ok, pid()}
  def start_link(id, docker_socket \\ {:local, "/var/run/docker.sock"}) do
    GenServer.start_link(__MODULE__, {id, docker_socket, self()})
  end

  def init({id, docker_socket, current}) do
    {:ok, socket} =
      :gen_tcp.connect(docker_socket, 0, [:binary, packet: :raw, active: true])

    body = Jason.encode!(%{"Detach" => false, "Tty" => true})

    request =
      """
      POST /exec/#{id}/start HTTP/1.1\r
      Host: localhost\r
      Content-Type: application/json\r
      Content-Length: #{byte_size(body)}\r
      Upgrade: tcp\r
      Connection: Upgrade\r
      \r
      #{body}
      """
      |> String.trim()

    :ok = :gen_tcp.send(socket, request)

    {:ok, %{socket: socket, id: id, current: current, header_buffer: "", mode: :headers}}
  end

  def handle_cast({:send_data, data}, state) do
    Logger.info("Sending data: #{inspect(data)}")
    :ok = :gen_tcp.send(state.socket, data)

    {:noreply, state}
  end

  def handle_info(
        {:tcp, socket, content},
        %{mode: :headers, header_buffer: header_buffer} = state
      ) do
    buffer = header_buffer <> content

    case String.split(buffer, "\r\n\r\n", parts: 2) do
      [headers, body] ->
        headers
        |> String.split("\r\n")
        |> Enum.each(&Logger.info("Received header: #{inspect(&1)}"))

        handle_info({:tcp, socket, body}, %{state | header_buffer: nil, mode: :tcp})

      _ ->
        # We haven't received the full headers yet
        {:noreply, %{state | header_buffer: buffer}}
    end
  end

  # Empty packet
  def handle_info({:tcp, _socket, ""}, state), do: {:noreply, state}

  def handle_info({:tcp, _socket, data}, state) do
    Logger.info("Received data: #{inspect(data)}")

    send(state.current, {:terminal_write, data})

    {:noreply, state}
  end

  def handle_info({:tcp_closed, _port}, state) do
    Logger.info("TCP connection closed")
    {:stop, :normal, state}
  end

  def handle_info(message, state) do
    Logger.warning("Received unknown message: #{inspect(message)}")
    {:noreply, state}
  end

  def send_data(client, data), do: GenServer.cast(client, {:send_data, data})

  def end_stream(client), do: GenServer.cast(client, :end_stream)
end
