defmodule DumpsterTest do
  use ExUnit.Case
  import Dumpster.Test
  alias Dumpster.Utils.Settings

  doctest Dumpster

  describe "read and write" do
    setup do
      {:ok, pid} =
        Dumpster.start_link(
          name: :dumpster,
          path: "/tmp",
          format: "dumpster_dump",
          compressed: false
        )

      ^pid = GenServer.whereis(:dumpster)

      {:ok, pid} =
        Dumpster.start_link(
          name: :dumpster_comp,
          path: "/tmp",
          format: "dumpster_dump",
          compressed: true
        )

      ^pid = GenServer.whereis(:dumpster_comp)

      on_exit(fn ->
        File.rm("/tmp/dumpster_dump.bin")
        File.rm("/tmp/dumpster_dump.bin.gz")
      end)

      {:ok,
       dumpster: :dumpster,
       compressed: :dumpster_comp,
       path: "/tmp/dumpster_dump.bin",
       path_comp: "/tmp/dumpster_dump.bin.gz"}
    end

    test "write and read uncompressed", %{dumpster: dumpster, path: path} do
      payload = random_bytes(500)
      Dumpster.dump(payload, dumpster)
      GenServer.stop(dumpster)
      Process.sleep(20)
      assert {:ok, [{_, ^payload}]} = Dumpster.retain(path)
    end

    test "write and read multible uncompressed", %{dumpster: dumpster, path: path} do
      a = random_bytes(500)
      b = random_bytes(500)
      Dumpster.dump(a, dumpster)
      Dumpster.dump(b, dumpster)
      GenServer.stop(dumpster)
      Process.sleep(20)
      assert {:ok, [{_, ^a}, {_, ^b}]} = Dumpster.retain(path)
    end

    test "write and read compressed", %{compressed: dumpster, path_comp: path} do
      payload = random_bytes(500)
      Dumpster.dump(payload, dumpster)
      GenServer.stop(dumpster)
      Process.sleep(20)
      assert {:ok, [{_, ^payload}]} = Dumpster.retain(path)
    end

    test "write and read multible compressed", %{compressed: dumpster, path_comp: path} do
      a = random_bytes(500)
      b = random_bytes(500)
      Dumpster.dump(a, dumpster)
      Dumpster.dump(b, dumpster)
      GenServer.stop(dumpster)
      Process.sleep(20)
      assert {:ok, [{_, ^a}, {_, ^b}]} = Dumpster.retain(path)
    end
  end
end
