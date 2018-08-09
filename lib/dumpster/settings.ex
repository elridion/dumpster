defmodule Dumpster.Settings do
  defstruct [
    :path,
    :compression,
    :mode,
    # :strategy
    :file
  ]

  def from_config(args \\ []) do
    Keyword.merge(Application.get_all_env(:dumpster), args)
    |> configure()
  end

  def configure(args) do
    %__MODULE__{
      path: Path.expand(args[:path] || "."),
      compression: args[:compression] || false,
      mode: [:binary] ++ if(args[:compression], do: [:compressed], else: []),
      file: args[:file] || nil
    }
    |> validate
  end

  def validate(%__MODULE__{} = settings) do
    cond do
      not File.dir?(settings.path) ->
        {:error, "invalid path"}

      not is_boolean(settings.compression) ->
        {:error, "compression has to be boolean"}

      not is_bitstring(settings.file) and not is_nil(settings.file) ->
        {:error, "filename has to be a string"}

      true ->
        {:ok, settings}
    end
  end
end
