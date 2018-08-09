defmodule Dumpster.Service do
  use GenServer

  require Logger

  alias Dumpster.Utils
  alias Dumpster.Service.Settings

  @moduledoc """
  Documentation for Dumpster.
  """

  def init(args) do
    Settings.from_config(args)
  end

  def terminate(_reason, %Settings{file: {file, _}}) when is_pid(file) do
    File.close(file)
  end

  def handle_cast({:dump, payload}, state) when is_binary(payload) do
    with {:ok, {file, path}} <- file(state) do
      Logger.info("Dumping into: #{path}")
      IO.binwrite(file, Utils.frame(payload))
      {:noreply, %Settings{state | file: {file, path}}}
    else
      {:error, reason} ->
        {:stop, Utils.translate_error(reason), state}
    end
  end

  defp file(%Settings{
         path: path,
         mode: mode,
         file: file_desc,
         format: format,
         compression: compression
       }) do
    path = Path.join(path, filename(format, compression))
    case file_desc do
      {nil, _} ->
        open(path, mode)
      {_file, ^path} ->
        {:ok, file_desc}
      {file, _path} ->
        File.close(file)
        open(path, mode)
    end
  end

  defp open(path, mode) do
    with {:ok, file} <- File.open(path, mode) do
      {:ok, {file, path}}
    else
      error -> error
    end
  end

  defp filename(format, compression) do
    EEx.eval_string(format, assigns: assigns()) <> (".bin" <> if compression, do: ".gz", else: "")
  end

  defp assigns(args \\ []) do
    [
      unix: DateTime.utc_now() |> DateTime.to_unix()
    ]
    |> Keyword.merge(args)
  end
end
