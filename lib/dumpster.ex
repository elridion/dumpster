defmodule Dumpster do
  require Logger

  import Path, only: [expand: 1]

  alias Dumpster.Utils

  @moduledoc ~S"""
    Binary dumps.
  """

  def start_link(args \\ []) do
    GenServer.start_link(Dumpster.Service, args, name: args[:name] || __MODULE__)
  end

  def child_spec(opts) do
    %{
      id: opts[:id] || opts[:name] || __MODULE__,
      start: {__MODULE__, :start_link, [opts]},
      type: :worker,
      restart: opts[:restart] || :permanent,
      shutdown: opts[:shutdown] || 500
    }
  end

  def dump(payload, target \\ __MODULE__) when is_binary(payload) do
    GenServer.cast(target, {:dump, payload})
    payload
  rescue
    _err ->
      Logger.error("dumping payload failed")
      payload
  end

  def retain(path) do
    with {:ok, file} <- File.open(expand(path), derive_mode(path)),
         <<payload::binary>> <- IO.binread(file, :all),
         payload <- Utils.unframe(payload) do
      # Logger.info("Reading from: #{path}")

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
