defmodule Host.Docker.Client do
  use Tesla

  require Logger

  plug Tesla.Middleware.BaseUrl, "http+unix://%2Fvar%2Frun%2Fdocker.sock"
  plug Tesla.Middleware.JSON

  adapter(Tesla.Adapter.Hackney, recv_timeout: 30_000)

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

  def get_container(id) do
    case get("/containers/#{id}/json") do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def get_logs(container_id) do
    case get("/containers/#{container_id}/logs?stdout=1&stderr=1") do
      {:ok, response} ->
        {:ok, response.body}

      {:error, reason} ->
        {:error, reason}
    end
  end
end
