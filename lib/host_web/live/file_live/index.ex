defmodule HostWeb.FileLive.Index do
  use HostWeb, :live_view

  alias Host.Files

  @impl true
  def mount(_params, _session, socket) do
    {:ok, stream(socket, :files, Files.list_files())}
  end

  @impl true
  def handle_params(params, _url, socket) do
    {:noreply, apply_action(socket, socket.assigns.live_action, params)}
  end

  defp apply_action(socket, :index, _params) do
    socket
    |> assign(:page_title, "Listing Files")
    |> assign(:file, nil)
  end
end
