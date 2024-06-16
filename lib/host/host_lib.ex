defmodule Host.HostLib do
  use Rustler,
    otp_app: :host,
    crate: :hostlib

  # When loading a NIF module, dummy clauses for all NIF function are required.
  # NIF dummies usually just error out when called when the NIF is not loaded, as that should never normally happen.
  def list_files(_arg1), do: :erlang.nif_error(:nif_not_loaded)
end
