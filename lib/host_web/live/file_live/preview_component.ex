defmodule HostWeb.FileLive.PreviewComponent do
  use HostWeb, :live_component

  alias Host.Files

  @max_file_size 1_024 * 1_024

  def update(assigns, socket) do
    {:ok,
     socket
     |> assign(:path, assigns.path)
     |> assign(:file, assigns.file)}
  end

  def render(assigns) do
    ~H"""
    <div class="my-6">
      <%= cond do %>
        <% Files.File.is_text(@file) -> %>
          <.text_preview file={@file} />
        <% Files.File.is_image(@file) -> %>
          <.image_preview file={@file} path={@path} />
        <% Files.File.is_video(@file) -> %>
          <.video_preview file={@file} path={@path} />
        <% Files.File.is_audio(@file) -> %>
          <.audio_preview file={@file} path={@path} />
        <% true -> %>
          File cannot be previewed
      <% end %>
    </div>
    """
  end

  defp text_preview(assigns) do
    content =
      if assigns.file.size <= @max_file_size do
        File.read!(assigns.file.path)
      end

    assigns = assign(assigns, content: content)

    ~H"""
    <%= if is_nil(@content) do %>
      File is too large to preview
    <% else %>
      <pre
        phx-hook="EditorHook"
        id="editor-area"
        data-readonly="true"
        data-lang={Files.File.monaco_language(@file)}
        class="whitespace-pre-wrap"
      ><%= @content %></pre>
    <% end %>
    """
  end

  def image_preview(assigns) do
    ~H"""
    <.link navigate={~p"/files/raw/#{assigns.path}"}>
      <img src={~p"/files/raw/#{assigns.path}"} class="mx-auto py-5 max-h-[75vh] max-w-[75vw]" />
    </.link>
    """
  end

  def video_preview(assigns) do
    ~H"""
    <video controls playsinline class="mx-auto py-5 max-h-[75vh]">
      <source src={~p"/files/raw/#{assigns.path}"} type={@file.mime_type} />
    </video>
    """
  end

  def audio_preview(assigns) do
    ~H"""
    <audio controls class="mx-auto">
      <source src={~p"/files/raw/#{assigns.path}"} type={@file.mime_type} />
    </audio>
    """
  end
end
