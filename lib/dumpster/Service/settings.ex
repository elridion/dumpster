defmodule Dumpster.Service.Settings do
  defstruct [
    :path,
    :compression,
    :mode,
    :file,
    :format
  ]

  def from_config(args \\ []) do
    Keyword.merge(Application.get_all_env(:dumpster), args)
    |> configure()
  end

  def configure(args) do
    %__MODULE__{
      path: Path.expand(args[:path] || "."),
      compression: args[:compression] || false,
      mode: [:write] ++ if(args[:compression], do: [:compressed], else: []),
      file: {nil, nil},
      format: args[:format] || "dump_<%= @unix %>"
    }
    |> validate
  end

  def validate(%__MODULE__{} = settings) do
    cond do
      not File.dir?(settings.path) ->
        {:error, "invalid path"}

      not is_boolean(settings.compression) ->
        {:error, "compression has to be boolean"}

      true ->
        {:ok, settings}
    end
  end
end
