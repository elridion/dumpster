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

  def child_spec(opts) do
    %{
      id: opts[:name] || __MODULE__,
      start: {__MODULE__, :start_link, opts},
      type: :worker,
      restart: opts[:restart] || :permanent,
      shutdown: opts[:shutdown] || 500
    }
  end
end
