defmodule MeasurementTest do
  alias Landmark.Measurement
  use ExUnit.Case

  doctest Landmark.Measurement

  describe "bearing" do
    test "calculates the bearing between two points" do
      point1 = %Geo.Point{coordinates: {-75, 45}}
      point2 = %Geo.Point{coordinates: {20, 60}}

      bearing = Measurement.bearing(point1, point2)

      assert_in_delta bearing, 37.75, 0.01
    end
  end

  describe "distance" do
    @point1 %Geo.Point{coordinates: {-75.343, 39.984}}
    @point2 %Geo.Point{coordinates: {-75.534, 39.123}}

    test "calculates the distance between two points in km" do
      distance = Measurement.distance(@point1, @point2)
      assert_in_delta distance, 97.12, 0.01
    end

    test "calculates the distance between two points in meters" do
      distance = Measurement.distance(@point1, @point2, :meters)
      assert_in_delta distance, 97129, 1
    end

    test "calculates the distance between two points in radians" do
      distance = Measurement.distance(@point1, @point2, :radians)
      assert_in_delta distance, 0.0152, 0.0001
    end
  end
end
