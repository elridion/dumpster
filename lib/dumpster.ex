defmodule Dumpster do
  require Logger

  import Path, only: [expand: 1]

  alias Dumpster.Utils

  @moduledoc ~S"""
  Simple Binary dumps.

  ## Usage

  Add Dumpster as a dependency in your `mix.exs`:

    defp deps() do
      [
        {:dumpster, "~> 1.0.0"}
      ]
    end

  Either add Dumpster to your applications in `mix.exs`:

    defp application do
      [
        mod: {MyApp, []},
        extra_applications: [
          :dumpster
        ]
      ]

  or start it manually by adding it in an Supervision tree:

    defmodule MyApp.Supervisor do
      use Supervisor

      def start_link(args \\ []) do
        [
          {Dumpster, []}
        ]
        |> Supervisor.start_link(build_children(), strategy: :one_for_one)
      end
    end

  ## Configuration
  Options are:
  * `:path` the folder in which the dumps are saved, defaults to the Application dir.
  * `:format` an [EEx](https://hexdocs.pm/eex/EEx.html) template String.
    Available parameters are `@unix @year @month @day @hour @minute @second`, defaults to `"dump_<%= @unix %>"`. File extensions are added as needed.
  * `:compressed` if `true` files are compressed with gzip.

  Dumpster can be configured either by using the config files or during runtime via the arguments.
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

  @doc ~S"""
  Dumps the payload and returns it, resulting in a Plug-like behaviour.

    iex> bin = <<1, 2, 3, 4, 5>>
    <<1, 2, 3, 4, 5>>
    iex> ^bin = Dumpster.dump(bin)
    <<1, 2, 3, 4, 5>>
  """
  def dump(payload, target \\ __MODULE__) when is_binary(payload) do
    GenServer.cast(target, {:dump, payload, :os.system_time(:seconds)})
    payload
  rescue
    _err ->
      Logger.error("dumping payload failed")
      payload
  end

  @doc """
  Opens and fetches all dumps from the given file.
  """
  def retain(path) do
    with {:ok, file} <- File.open(expand(path), derive_mode(path)),
         <<payload::binary>> <- IO.binread(file, :all),
         payload <- Utils.decode(payload) do
      File.close(file)
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
