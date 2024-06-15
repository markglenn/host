defmodule HostWeb.FileLive.PreviewComponent do
  use HostWeb, :live_component

  alias Host.Files

  @max_file_size 1_024 * 1_024

  def update(assigns, socket) do
    file = assigns.file

    content =
      if file.size <= @max_file_size && (Files.File.is_text(file) or Files.File.is_image(file)) do
        File.read!(file.path)
      end

    {:ok,
     socket
     |> assign(:content, content)
     |> assign(:file, file)}
  end

  def render(assigns) do
    ~H"""
    <div class="my-6">
      <%= cond do %>
        <% Files.File.is_text(@file) && !is_nil(@content) -> %>
          <.text_preview content={@content} file={@file} />
        <% Files.File.is_image(@file) -> %>
          <.image_preview file={@file} content={@content} />
        <% true -> %>
          File cannot be previewed
      <% end %>
    </div>
    """
  end

  defp text_preview(assigns) do
    ~H"""
    <pre
      phx-hook="EditorHook"
      id="editor-area"
      data-readonly="true"
      data-lang={Files.File.monaco_language(@file)}
      class="whitespace-pre-wrap"
    ><%= @content %></pre>
    """
  end

  def image_preview(assigns) do
    ~H"""
    <img
      src={"data:#{@file.mime_type};base64," <> Base.encode64(@content)}
      class="mx-auto py-5 max-h-[75vh] max-w-[75vw]"
    />
    """
  end
end
