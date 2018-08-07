defmodule Dumpster do
  @moduledoc ~S"""
    Binary dumps.
  """

  def start_link(args \\ []) do
    GenServer.start_link(Dumpster.Service, args, name: args[:name] || __MODULE__)
  end

  def dump(target \\ __MODULE__, payload) when is_binary(payload) do
    GenServer.cast(target, {:dump, payload})
  end
end
