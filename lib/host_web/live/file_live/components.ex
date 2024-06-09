defmodule HostWeb.FileLive.Components do
  use Phoenix.LiveComponent
  # import HostWeb.CoreComponents

  alias Host.Files.File

  attr :file, :map, required: true, doc: "The file to display."
  def storage_size(%{file: %File{file_type: :directory}} = assigns), do: ~H"&ndash; &ndash;"

  def storage_size(%{file: %File{size: size}} = assigns) when size < 1024,
    do: ~H"<%= @file.size %> B"

  def storage_size(%{file: %File{size: size}} = assigns) when size < 1024 * 1024,
    do: ~H"<%= Float.round(@file.size / 1024.0, 1) %> KB"

  def storage_size(%{file: %File{size: size}} = assigns) when size < 1024 * 1024 * 1024,
    do: ~H"<%= Float.round(@file.size / (1024.0 * 1024.0), 1) %> MB"

  def storage_size(%{file: %File{}} = assigns),
    do: ~H"<%= Float.round(@file.size / (1024.0 * 1024.0 * 1024.0), 1) %> GB"
end
