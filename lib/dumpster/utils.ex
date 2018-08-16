defmodule Dumpster.Utils do
  require Logger

  @doc ~S"""
  Encodes the given binary and (unix-)timestamp into a chunk.
  """
  def encode(timestamp, payload) when is_binary(payload) and is_integer(timestamp) do
    <<timestamp::unsigned-integer-32, payload::binary>>
    |> frame()
  end

  @doc ~S"""
  Tries to decode all chunks in the given binary.
  """
  def decode(payload) when is_binary(payload) do
    unframe(payload)
    |> Enum.map(fn <<timestamp::unsigned-integer-32, payload::binary>> ->
      {timestamp, payload}
    end)
  end

  defp frame(payload) do
    <<byte_size(payload)::unsigned-integer-32, payload::binary>>
  end

  defp unframe(<<_::size(0)>>) do
    []
  end

  defp unframe(<<size::unsigned-integer-32, payload::bytes-size(size), rest::binary>>) do
    [payload | unframe(rest)]
  end

  defp unframe(_) do
    Logger.error("Part of the Frame payload is missing")
    []
  end

  @doc """
  Maps the Elixir File error reasons onto their respective reasons
  """
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

  def zero_pad(number, count \\ 2, padding \\ "0") when is_integer(number) do
    number
    |> Integer.to_string()
    |> String.pad_leading(count, padding)
  end
end
