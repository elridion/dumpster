defmodule Dumpster.Service do
  use GenServer

  alias Dumpster.Utils

  @moduledoc """
  Dumpster GenServer.
  """

  defmodule State do
    @moduledoc false

    defstruct [
      :path,
      :compressed,
      :mode,
      :file,
      :format
    ]

    def validate(%State{} = settings) do
      cond do
        not File.dir?(settings.path) ->
          {:error, "invalid path"}

        not is_boolean(settings.compressed) ->
          {:error, "compressed has to be boolean"}

        true ->
          {:ok, settings}
      end
    end
  end

  def init(rt_args) do
    args = Keyword.merge(Application.get_all_env(:dumpster), rt_args)

    %State{
      path: Path.expand(args[:path] || "."),
      compressed: args[:compressed] || false,
      mode: [:write] ++ if(args[:compressed], do: [:compressed], else: []),
      file: {nil, nil},
      format: args[:format] || "dump_<%= @unix %>"
    }
    |> State.validate()
  end

  def terminate(_reason, %State{file: {file, _}}) when is_pid(file) do
    File.close(file)
  end

  def handle_cast({:dump, payload, timestamp}, state) when is_binary(payload) do
    with {:ok, {file, path}} <- file(state) do
      IO.binwrite(file, Utils.encode(timestamp, payload))
      {:noreply, %State{state | file: {file, path}}}
    else
      {:error, reason} ->
        {:stop, Utils.translate_error(reason), state}
    end
  end

  defp file(%State{
         path: path,
         mode: mode,
         file: file_desc,
         format: format,
         compressed: compressed
       }) do
    path = Path.join(path, filename(format, compressed))

    case file_desc do
      {nil, _} ->
        open(path, mode)

      {_file, ^path} ->
        {:ok, file_desc}

      {file, _path} ->
        :ok = File.close(file)
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

  defp filename(format, compressed) do
    EEx.eval_string(format, assigns: assigns()) <> ".bin" <> if compressed, do: ".gz", else: ""
  end

  defp assigns(args \\ []) do
    import Utils, only: [zero_pad: 1]
    {{year, month, day}, {hour, minute, second}} = :calendar.local_time()
    unix = :os.system_time(:seconds)

    [
      unix: unix,
      year: year,
      month: zero_pad(month),
      day: zero_pad(day),
      hour: zero_pad(hour),
      minute: zero_pad(minute),
      second: zero_pad(second)
    ]
    |> Keyword.merge(args)
  end
end
