defmodule Nif do
  @on_load :init

  def init do
    :ok = :erlang.load_nif(~c"./priv/nif", 0)
  end

  def sum(_, _) do
    exit(:nif_library_not_loaded)
  end

  def vir_connect_open(_uri), do: exit(:nif_library_not_loaded)
  def vir_connect_close(_conn), do: exit(:nif_library_not_loaded)
end
