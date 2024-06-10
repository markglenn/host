defmodule Host.Files.File do
  defstruct [:name, :file_type, :size, :modified_date, :path, :mime_type, :extension]

  @type t :: %__MODULE__{
          name: String.t(),
          file_type: :directory | :file,
          size: integer(),
          modified_date: NaiveDateTime.t(),
          path: String.t() | nil,
          mime_type: String.t() | nil,
          extension: String.t()
        }

  @extension_to_language %{
    "abap" => "abap",
    "bat" => "bat",
    "cmd" => "bat",
    "bib" => "bibtex",
    "clj" => "clojure",
    "cljs" => "clojurescript",
    "coffee" => "coffeescript",
    "cpp" => "cpp",
    "cc" => "cpp",
    "cxx" => "cpp",
    "h" => "cpp",
    "hh" => "cpp",
    "hpp" => "cpp",
    "cs" => "csharp",
    "csharp" => "csharp",
    "css" => "css",
    "diff" => "diff",
    "patch" => "diff",
    "dockerfile" => "dockerfile",
    "fs" => "fsharp",
    "fsi" => "fsharp",
    "ml" => "fsharp",
    "mls" => "fsharp",
    "glsl" => "glsl",
    "go" => "go",
    "groovy" => "groovy",
    "hbs" => "handlebars",
    "html" => "html",
    "htm" => "html",
    "ini" => "ini",
    "properties" => "ini",
    "toml" => "ini",
    "java" => "java",
    "js" => "javascript",
    "es6" => "javascript",
    "jsx" => "javascript",
    "json" => "json",
    "jl" => "julia",
    "kt" => "kotlin",
    "less" => "less",
    "lua" => "lua",
    "md" => "markdown",
    "markdown" => "markdown",
    "m" => "objective-c",
    "mm" => "objective-c",
    "pl" => "perl",
    "php" => "php",
    "txt" => "plaintext",
    "text" => "plaintext",
    "ps1" => "powershell",
    "psm1" => "powershell",
    "psd1" => "powershell",
    "py" => "python",
    "r" => "r",
    "rhistory" => "r",
    "rprofile" => "r",
    "rt" => "r",
    "cshtml" => "razor",
    "rb" => "ruby",
    "rs" => "rust",
    "sc" => "scala",
    "scala" => "scala",
    "scss" => "scss",
    "sh" => "shell",
    "bash" => "shell",
    "sql" => "sql",
    "swift" => "swift",
    "ts" => "typescript",
    "tsx" => "typescript",
    "vb" => "vb",
    "xml" => "xml",
    "yml" => "yaml",
    "yaml" => "yaml"
  }

  @spec monaco_language(t()) :: String.t()
  def monaco_language(%__MODULE__{extension: extension}) when extension != "",
    do: Map.get(@extension_to_language, extension, "plaintext")

  def monaco_language(%__MODULE__{name: name}) do
    case String.downcase(name) do
      "makefile" -> "makefile"
      "dockerfile" -> "dockerfile"
      _ -> "plaintext"
    end
  end
end
