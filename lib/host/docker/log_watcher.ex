defmodule Host.Docker.LogWatcher do
  alias Mint.HTTP

  require Logger

  def connect(container_id) do
    current = self()

    spawn_link(fn ->
      {:ok, conn} =
        HTTP.connect(:http, {:local, "/var/run/docker.sock"}, 0, hostname: "localhost")

      {:ok, conn, _request_ref} =
        HTTP.request(
          conn,
          "GET",
          "/containers/#{container_id}/logs?stdout=true&follow=true",
          [],
          ""
        )

      receive_messages(conn, current)
    end)
  end

  def receive_messages(conn, pid) do
    receive do
      message ->
        {:ok, conn, responses} = HTTP.stream(conn, message)

        cont =
          Enum.reduce(responses, true, fn
            {:data, _, data}, cont ->
              send(pid, {:docker_log, data})
              cont

            {:done, _}, _ ->
              HTTP.close(conn)
              false

            response, cont ->
              Logger.info("other: #{inspect(response)}")
              cont
          end)

        if cont do
          receive_messages(conn, pid)
        end
    end
  end
end
