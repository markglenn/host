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
end
