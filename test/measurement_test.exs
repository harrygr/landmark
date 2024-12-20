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

    test "getting the centroid of a multipoint" do
      multipoint = %Geo.MultiPoint{
        coordinates: [{2, 2}, {2, 4}, {6, 4}, {6, 2}]
      }

      assert Measurement.centroid(multipoint) == %Geo.Point{coordinates: {4, 3}}
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

  describe "bbox" do
    test "getting the bbox for a point" do
      point = %Geo.Point{
        coordinates: {102.0, 0.5}
      }

      assert Measurement.bbox(point) == {102, 0.5, 102, 0.5}
    end

    test "getting the bbox for a multipoint" do
      multipoint = %Geo.MultiPoint{
        coordinates: [
          {102.0, -10.0},
          {103.0, 1.0},
          {104.0, 0.0},
          {130.0, 4.0}
        ]
      }

      assert Measurement.bbox(multipoint) == {102, -10, 130, 4}
    end

    test "getting the bbox for a polygon" do
      polygon = %Geo.Polygon{
        coordinates: [
          [{101.0, 0.0}, {101.0, 1.0}, {100.0, 1.0}, {100.0, 0.0}, {101.0, 0.0}]
        ]
      }

      assert Measurement.bbox(polygon) == {100, 0, 101, 1}
    end
  end

  describe "rhumb destination calculation" do
    test "travelling 100km 90°" do
      origin = %Geo.Point{coordinates: {-75, 39}}
      destination = Landmark.Measurement.rhumb_destination(origin, 100, 90)

      assert destination == %Geo.Point{coordinates: {-73.84279077386554, 39.0}}
    end

    test "travelling 100km 180°" do
      origin = %Geo.Point{coordinates: {-75, 39}}
      destination = Landmark.Measurement.rhumb_destination(origin, 100, 180)

      assert destination == %Geo.Point{coordinates: {-75.0, 38.10067952334886}}
    end

    test "getting a destination over the meridian" do
      origin = %Geo.Point{coordinates: {-179.5, -16.5}}
      destination = Landmark.Measurement.rhumb_destination(origin, 100, -90)

      assert destination == %Geo.Point{coordinates: {-180.43794531333336, -16.5}}
    end
  end
end
