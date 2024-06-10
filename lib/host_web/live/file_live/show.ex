defmodule HostWeb.FileLive.Show do
  alias Host.Files
  use HostWeb, :live_view

  @impl true
  def mount(_params, _session, socket) do
    {:ok, socket}
  end

  @impl true
  def handle_params(%{"path" => path}, _, socket) do
    file =
      Files.get_file!(path, "../winestyr")
      |> IO.inspect()

    content =
      if file.mime_type == "text/plain" do
        File.read!(file.path)
      else
        "This file is not a text file."
      end

    {:noreply,
     socket
     |> assign(:file, file)
     |> assign(:content, content)
     |> assign(:page_title, page_title(socket.assigns.live_action))}
  end

  defp page_title(:show), do: "Show File"
end
