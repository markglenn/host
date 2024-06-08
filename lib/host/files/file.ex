defmodule Host.Files.File do
  defstruct [:name, :file_type, :size, :modified_date, :path, :mime_type]

  @type t :: %__MODULE__{
          name: String.t(),
          file_type: :directory | :file,
          size: integer(),
          modified_date: NaiveDateTime.t(),
          path: String.t() | nil,
          mime_type: String.t() | nil
        }

  def storage_size(%__MODULE__{file_type: :directory}), do: "- -"

  def storage_size(%__MODULE__{size: size}) when size < 1024 do
    "#{size} B"
  end

  def storage_size(%__MODULE__{size: size}) when size < 1024 * 1024 do
    "#{Float.round(size / 1024.0, 1)} KB"
  end

  def storage_size(%__MODULE__{size: size}) when size < 1024 * 1024 * 1024 do
    "#{Float.round(size / 1024.0 * 1024, 1)} MB"
  end

  def storage_size(%__MODULE__{size: size}) do
    "#{Float.round(size / 1024.0 * 1024 * 1024, 1)} GB"
  end
end
