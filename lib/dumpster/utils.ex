defmodule Dumpster.Utils do
  defmodule Settings do
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

  def translate_error(error) do
    case error do
      :enoent ->
        "a component of the file name does not exist"

      :enotdir ->
        "a component of the file name is not a directory"

      :enospc ->
        "there is no space left on the device"

      :eacces ->
        "missing permission for reading/writing the file or searching one of the parent directories"

      :eisdir ->
        "the named file is a directory"

      :enomem ->
        "there is not enough memory for the contents of the file"

      _ ->
        error
    end
  end
end
