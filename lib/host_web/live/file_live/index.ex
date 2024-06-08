defmodule HostWeb.FileLive.Index do
  use HostWeb, :live_view

  alias Host.Files
  alias Host.Files.File

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"path" => path} = params, _url, socket) do
    {:ok, files} =
      case path do
        [] -> Files.list_files("", "")
        _ -> Files.list_files(Path.join(path), "")
      end

    socket =
      socket
      |> assign(:files, files)
      |> assign(:path, path)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"path" => path} = _params) do
    socket
    |> assign(:page_title, "Listing Files: #{path}")
    |> assign(:file, nil)
  end

  def file_path(%File{file_type: :directory} = file), do: "/files/#{file.path}"
  def file_path(%File{} = file), do: "/file/#{file.path}"

  def file_icon(%File{file_type: :directory}), do: "hero-folder"
  def file_icon(%File{mime_type: "image/" <> _}), do: "hero-photo"
  def file_icon(%File{mime_type: "application/" <> _}), do: "hero-document"
  def file_icon(%File{mime_type: "text/" <> _}), do: "hero-document-text"
end
