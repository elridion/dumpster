defmodule Dumpster.Retrieve do
  import Path, only: [expand: 1]

  require Logger

  alias Dumpster.Utils

  def from_file(path) do
    with {:ok, file} <- File.open(expand(path), derive_mode(path)),
         <<payload::binary>> <- IO.binread(file, :all) do
      Logger.info("Reading from: #{path}")
      {:ok, payload}
    else
      :eof ->
        {:error, "encountered end of file"}

      {:error, reason} ->
        {:error, Utils.translate_error(reason)}
    end
  end

  defp derive_mode(path) do
    if String.ends_with?(path, ".gz") do
      [:read, :compressed]
    else
      [:read]
    end
  end
end
