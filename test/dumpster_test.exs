defmodule DumpsterTest do
  use ExUnit.Case

  import Dumpster.Test

  alias Dumpster.Utils.Settings

  describe "read and write" do
    setup do
      {:ok, pid} = Dumpster.start_link(name: :dumpster, path: "/tmp", file: "dumpster_dump", compression: false)
      ^pid = GenServer.whereis(:dumpster)

      {:ok, pid} =
        Dumpster.start_link(
          name: :dumpster_comp,
          path: "/tmp",
          file: "dumpster_dump",
          compression: true
        )
      ^pid = GenServer.whereis(:dumpster_comp)

      on_exit fn ->
        File.rm("/tmp/dumpster_dump.bin")
        File.rm("/tmp/dumpster_dump.bin.gz")
      end

      {:ok,
       dumpster: :dumpster,
       compressed: :dumpster_comp,
       path: "/tmp/dumpster_dump.bin",
       path_comp: "/tmp/dumpster_dump.bin.gz"}
    end

    test "write and read uncompressed", %{dumpster: dumpster, path: path} do
      payload = random_bytes(128)
      Dumpster.dump(dumpster, payload)
      assert {:ok, ^payload} = Dumpster.Retrieve.from_file(path)
    end

    test "write and read compressed", %{compressed: dumpster, path_comp: path} do
      payload = random_bytes(128)
      Dumpster.dump(dumpster, payload)
      assert {:ok, ^payload} = Dumpster.Retrieve.from_file(path)
    end
  end
end
