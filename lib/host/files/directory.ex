defmodule Host.Files.Directory do
  def is_root(path, base_path) do
    case parent_path(path, base_path) do
      {:ok, _parent} -> false
      :error -> true
    end
  end

  @spec parent_path(Path.t(), Path.t()) :: {:ok, String.t()} | :error
  def parent_path(path, base_path) do
    path
    |> Path.join("..")
    |> Path.safe_relative(base_path)
  end
end
