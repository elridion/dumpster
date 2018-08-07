defmodule Dumpster.Service do
  use GenServer

  require Logger

  alias Dumpster.Utils
  alias Dumpster.Utils.Settings

  @moduledoc """
  Documentation for Dumpster.
  """

  def init(args) do
    Settings.from_config(args)
  end

  def handle_cast({:dump, payload}, state) when is_binary(payload) do
    with path <- Path.join(state.path, file_name(state)),
         :ok <- File.write(path, payload, state.mode) do
      Logger.info("Dumping into: #{path}")
      {:noreply, state}
    else
      {:error, reason} ->
        {:stop, Utils.translate_error(reason), state}
    end
  end

  def file_name(%Settings{compression: compression, file: file}) do
    base = file || "dump_#{DateTime.utc_now() |> DateTime.to_unix()}"

    base <> ".bin" <> if compression, do: ".gz", else: ""
  end
end
