defmodule DemoElixirTest do
  use ExUnit.Case
  doctest DemoElixir

  test "greets the world" do
    assert DemoElixir.hello() == :world
  end
end
