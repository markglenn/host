defmodule HostWeb.FileLive.Show do
  alias Host.Files
  use HostWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"path" => path}, _, socket) do
    {:noreply,
     socket
     |> assign(:file, Files.get_file!(path, "example"))
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:show), do: "Show File"
end
