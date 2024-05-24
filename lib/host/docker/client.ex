defmodule Host.Docker.Client do
  use Tesla

  require Logger

  plug Tesla.Middleware.BaseUrl, "http://localhost"
  plug Tesla.Middleware.JSON

  adapter(Host.Docker.FinchAdapter, name: Host.Finch, unix_socket: "/var/run/docker.sock")

  @spec list_containers(keyword()) :: {:error, any()} | {:ok, any()}
  def list_containers(opts \\ []) do
    # Determine if we should get all containers or not
    all = Keyword.get(opts, :all, false)

    case get("/containers/json", query: [all: all]) do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec get_container(String.t()) :: {:error, any()} | {:ok, any()}
  def get_container(id) do
    case get("/containers/#{id}/json") do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec watch_container_logs(String.t()) :: pid()
  def watch_container_logs(container_id) do
    current = self()

    spawn_link(fn ->
      {:ok, env} =
        get("/containers/#{container_id}/logs?stdout=true&follow=true",
          opts: [adapter: [response: :stream]]
        )

      env.body
      |> Stream.each(&send(current, {:docker_log_message, &1}))
      |> Stream.run()
    end)
  end
end
