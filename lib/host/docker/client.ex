defmodule Host.Docker.Client do
  use Tesla

  require Logger

  plug Tesla.Middleware.BaseUrl, "http://localhost"
  plug Tesla.Middleware.JSON

  # Start the shell with the user's shell
  @exec_command ["/bin/sh", "-c", "eval $(grep ^$(id -un): /etc/passwd | cut -d : -f 7-)"]

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

  @spec get_container(Container.id()) :: {:error, any()} | {:ok, map()}
  def get_container(container_id) do
    case get("/containers/#{container_id}/json") do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec restart_container(Container.id()) :: {:error, any()} | {:ok, any()}
  def restart_container(container_id) do
    case post("/containers/#{container_id}/restart", %{}) do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def stop_container(container_id, opts \\ []) do
    wait = Keyword.get(opts, :wait, 10)

    url = Tesla.build_url("/containers/#{container_id}/stop", t: wait)

    case post(url, %{}) do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def start_container(container_id) do
    case post("/containers/#{container_id}/start", %{}) do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  @spec watch_logs(Container.id()) :: {:ok, pid()}
  def watch_logs(container_id) do
    current = self()

    pid =
      spawn_link(fn ->
        url = Tesla.build_url("/containers/#{container_id}/logs", stdout: "true", follow: "true")

        case get(url, opts: [adapter: [response: :stream]]) do
          {:ok, env} ->
            env.body
            |> Stream.each(&send(current, {:terminal_read, &1}))
            |> Stream.run()

          _ ->
            Logger.error("Failed to get logs for container: #{container_id}")
        end
      end)

    {:ok, pid}
  end

  @spec create_tty_instance(Container.id()) :: {:error, any()} | {:ok, Container.id()}
  def create_tty_instance(container_id) do
    case post("/containers/#{container_id}/exec", %{
           AttachStdin: true,
           AttachStdout: true,
           AttachStderr: true,
           Tty: true,
           Cmd: @exec_command
         }) do
      {:ok, response} ->
        {:ok, response.body["Id"]}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
