defmodule HostWeb.FileLive.BreadcrumbsComponent do
  use HostWeb, :html

  def breadcrumbs(assigns) do
    ~H"""
    <div class="flex items-center space-x-2">
      <.breadcrumb_segments path={@path} />
    </div>
    """
  end

  defp breadcrumb_segments(%{path: []} = assigns) do
    ~H"""
    <.icon name="hero-home" />
    """
  end

  defp breadcrumb_segments(assigns) do
    ~H"""
    <.link navigate={~p"/files/listing"} class="text-blue-500">
      <.icon name="hero-home" />
    </.link>

    <%= for {part, i} <- Enum.with_index(List.delete_at(@path, -1)) do %>
      <.icon name="hero-chevron-right" />
      <.link navigate={get_path(@path, i + 1)} class="text-blue-500">
        <%= part %>
      </.link>
    <% end %>

    <.icon name="hero-chevron-right" />

    <span><%= List.last(@path) %></span>
    """
  end

  defp get_path(path_segments, position) do
    (["/files", "listing"] ++ Enum.take(path_segments, position))
    |> Path.join()
  end
end
