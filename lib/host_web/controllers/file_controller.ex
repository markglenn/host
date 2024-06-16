defmodule HostWeb.FileController do
  @moduledoc """
  Serves files directly
  """
  use HostWeb, :controller

  require Logger

  alias Host.Files

  def show(conn, %{"path" => path}) do
    # Get the actual path on the drive for this file
    file = Files.get_file!(path, "../winestyr")

    # accept-ranges headers required for chrome to seek via currentTime
    conn
    |> put_resp_header("content-type", MIME.from_path(file.path))
    |> put_resp_header("accept-ranges", "bytes")
    |> send_file(200, file.path)
  end
end
