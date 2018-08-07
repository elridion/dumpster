ExUnit.start()

defmodule Dumpster.Test do
  def random_bytes(acc \\ <<>>, size) when is_integer(size) do
    if byte_size(acc) < size do
      <<:rand.uniform()::float, acc::binary>>
      |> random_bytes(size)
    else
      <<ret::bytes-size(size), _rest::binary>> = acc
      ret
    end
  end
end
