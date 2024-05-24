defmodule Host.Docker.TtyClient do
  alias Mint.HTTP

  # docker exec -it a7fb1b79f45776965d10f1f395f774c1774c893a362fdecfc5ec110fb7295aea /bin/sh -c eval $(grep ^$(id -un): /etc/passwd | cut -d : -f 7-)
  def start do
    {:ok, conn} =
      HTTP.connect(:http, {:local, "/var/run/docker.sock"}, 0, hostname: "localhost")

    path =
      "/containers/1a0aefb25f0ff88546bfd5805b07acb917393385efec88a7b51c1501737e54e0/attach/ws?stream=1&stdin=1&stdout=1&stderr=1"

    {:ok, conn, ref} = Mint.WebSocket.upgrade(:ws, conn, path, []) |> IO.inspect()

    http_get_message = receive(do: (message -> message))

    {:ok, conn, [{:status, ^ref, status}, {:headers, ^ref, resp_headers}, {:done, ^ref}]} =
      Mint.WebSocket.stream(conn, http_get_message)

    {:ok, conn, websocket} = Mint.WebSocket.new(conn, ref, status, resp_headers)

    # send the hello world frame
    {:ok, websocket, data} =
      Mint.WebSocket.encode(websocket, {:text, "hello world"})

    {:ok, conn} = Mint.WebSocket.stream_request_body(conn, ref, data)

    # receive the hello world reply frame
    hello_world_echo_message = receive(do: (message -> message)) |> IO.inspect()
    {:ok, conn, [{:data, ^ref, data}]} = Mint.WebSocket.stream(conn, hello_world_echo_message)
    {:ok, websocket, [{:text, "hello world"}]} = Mint.WebSocket.decode(websocket, data)
  end
end
