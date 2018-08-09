defmodule Dumpster.Utils do
  def frame(payload) when is_binary(payload) do
    <<byte_size(payload)::unsigned-integer, payload::binary>>
  end

  def unframe(<<size::unsigned-integer, payload::bytes-size(size), rest::binary>>) do
    {payload, rest}
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
