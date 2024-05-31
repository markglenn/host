defmodule Host.Files.File do
  defstruct [:name, :file_type, :size]

  @type t :: %__MODULE__{
          name: String.t(),
          file_type: String.t(),
          size: integer()
        }
end
