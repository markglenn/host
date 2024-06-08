defmodule Host.Files do
  @moduledoc """
  The Files context.
  """

  alias Host.HostLib
  alias File, as: ElixirFile
  alias Host.Files.File

  @doc """
  Returns the list of files.

  ## Examples

      iex> list_files()
      [%File{}, ...]

  """
  @spec list_files(Path.t(), Path.t()) :: {:ok, [File.t()]} | {:error, String.t()}
  def list_files(path, relative_to) do
    with {:ok, safe_path} <- Path.safe_relative(path, relative_to),
         relative_path <- Path.join(relative_to, safe_path),
         {:ok, files} <- HostLib.list_files(relative_path) do
      # Map the files to include the path
      files =
        files
        |> Enum.map(&assign_path(&1, relative_path))
        |> Enum.map(&assign_mime_type/1)
        |> Enum.sort_by(&String.downcase(&1.name))

      {:ok, files}
    else
      :error ->
        {:error, "Invalid path"}
    end
  end

  def get_file!(path, relative_path) do
    path = Path.join(path)

    with {:ok, safe_path} <-
           Path.safe_relative(path, relative_path),
         relative_path <- Path.join(relative_path, safe_path),
         {:ok, stats} <- ElixirFile.lstat(relative_path),
         {:ok, modified_date} <- NaiveDateTime.from_erl(stats.mtime) do
      %File{
        name: Path.basename(relative_path),
        file_type: :file,
        size: stats.size,
        modified_date: modified_date,
        path: relative_path,
        mime_type: MIME.from_path(relative_path)
      }
    end
  end

  defp assign_path(%File{} = file, relative_path),
    do: Map.put(file, :path, Path.join(relative_path, file.name))

  defp assign_mime_type(%File{file_type: :directory} = file),
    do: Map.put(file, :mime_type, "text/directory")

  defp assign_mime_type(%File{} = file),
    do: Map.put(file, :mime_type, MIME.from_path(file.name))
end
