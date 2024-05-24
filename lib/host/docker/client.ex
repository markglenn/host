defmodule Host.Docker.Client do
  use Tesla

  require Logger

  plug Tesla.Middleware.BaseUrl, "http://localhost"
  plug Tesla.Middleware.JSON

  alias Host.Containers.Container

  adapter(Host.Docker.FinchAdapter, name: Host.Finch, unix_socket: "/var/run/docker.sock")

  @spec list_containers(keyword()) :: {:error, any()} | {:ok, list(map())}
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

  @spec get_container(Container.id_t()) :: {:error, any()} | {:ok, map()}
  def get_container(id) do
    case get("/containers/#{id}/json") do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec watch_logs(Container.id_t()) :: pid()
  def watch_logs(container_id) do
    current = self()

    spawn_link(fn ->
      {:ok, env} =
        get("/containers/#{container_id}/logs?stdout=true&follow=true",
          opts: [adapter: [response: :stream]]
        )

      env.body
      |> Stream.each(&send(current, {:terminal_write, &1}))
      |> Stream.run()
    end)
  end

  @spec create_tty_instance(Container.id_t()) :: {:error, any()} | {:ok, Container.id_t()}
  def create_tty_instance(id) do
    case post("/containers/#{id}/exec", %{
           AttachStdin: true,
           AttachStdout: true,
           AttachStderr: true,
           Tty: true,
           # Cmd: ["/bin/sh -c eval $(grep ^$(id -un): /etc/passwd | cut -d : -f 7-)"]
           Cmd: ["sh"]
         }) do
      {:ok, response} ->
        {:ok, response.body["Id"]}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
