defmodule HostWeb.FileLive.Index do
  use HostWeb, :live_view

  alias Host.Files
  alias Host.Files.File

  import HostWeb.FileLive.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"path" => path} = params, _url, socket) do
    {:ok, files} =
      case path do
        [] -> Files.list_files("", "example")
        _ -> Files.list_files(Path.join(path), "example")
      end

    socket =
      socket
      |> assign(:files, sort(files, params["sort_by"]))
      |> assign(:path, path)

    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, %{"path" => path} = _params) do
    socket
    |> assign(:page_title, "Listing Files: #{path}")
  end

  def file_path(%File{file_type: :directory} = file), do: "/files/#{file.path}"
  def file_path(%File{} = file), do: "/file/#{file.path}"

  def parent_path([_]), do: "/files"
  def parent_path([_ | _] = parts), do: "/files/#{Path.join(Enum.drop(parts, -1))}"

  def file_icon(%File{file_type: :directory}), do: "hero-folder"
  def file_icon(%File{mime_type: "image/" <> _}), do: "hero-photo"
  def file_icon(%File{mime_type: "application/" <> _}), do: "hero-document"
  def file_icon(%File{mime_type: "text/" <> _}), do: "hero-document-text"

  defp sort(files, "kind"), do: Enum.sort_by(files, &String.downcase(&1.name))
  defp sort(files, _), do: Enum.sort_by(files, &String.downcase(&1.name))

  defp path_header_icon(%{path: []} = assigns) do
    ~H"""
    <.icon name="hero-folder-open" />
    """
  end

  defp path_header_icon(%{path: _} = assigns) do
    ~H"""
    <.link navigate={parent_path(@path)} class="text-blue-500">
      <.icon name="hero-chevron-left" />
    </.link>
    """
  end
end
