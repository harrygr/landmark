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

  describe "centroid" do
    test "getting the centroid of a point" do
      point = %Geo.Point{
        coordinates: {2, 3}
      }

      assert Measurement.centroid(point) == %Geo.Point{coordinates: {2, 3}}
    end

    test "getting the centroid of a polygon" do
      polygon = %Geo.Polygon{
        coordinates: [[{2, 2}, {2, 4}, {6, 4}, {6, 2}, {2, 2}]]
      }

      assert Measurement.centroid(polygon) == %Geo.Point{coordinates: {4, 3}}
    end

    test "getting the centroid of a polygon with a hole" do
      polygon = %Geo.Polygon{
        coordinates: [
          [{2, 2}, {2, 4}, {6, 4}, {6, 2}, {2, 2}],
          [{3, 3}, {3, 3.5}, {3.5, 4}, {4, 3}, {3, 3}]
        ]
      }

      assert Measurement.centroid(polygon) == %Geo.Point{coordinates: {3.6875, 3.1875}}
    end

    test "getting the centroid of a lineString" do
      linestring = %Geo.LineString{
        coordinates: [
          {4.86020565032959, 45.76884015325622},
          {4.85994815826416, 45.749558161214516}
        ]
      }

      assert Measurement.centroid(linestring) == %Geo.Point{
               coordinates: {4.860076904296875, 45.75919915723537}
             }
    end
  end
end
