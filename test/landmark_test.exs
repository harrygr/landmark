defmodule LandmarkTest do
  use ExUnit.Case
  doctest Landmark

  test "greets the world" do
    assert Landmark.hello() == :world
  end
end
