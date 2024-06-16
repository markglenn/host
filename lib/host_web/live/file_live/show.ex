defmodule HostWeb.FileLive.Show do
  use HostWeb, :live_view

  alias Host.Files
  alias HostWeb.FileLive.BreadcrumbsComponent
  alias HostWeb.FileLive.PreviewComponent
  import HostWeb.FileLive.Components

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"path" => path}, _, socket) do
    file = Files.get_file!(path, "../winestyr")

    {:noreply,
     socket
     |> assign(:path, path)
     |> assign(:file, file)
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:show), do: "Show File"
end
