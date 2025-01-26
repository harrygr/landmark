defmodule TransformationTest do
  use ExUnit.Case

  describe "translate" do
    test "translating a point" do
      geo = %Geo.Point{coordinates: {-75, 39}, properties: %{name: "foo"}}

      translated = Landmark.Transformation.translate(geo, 100, 90)

      assert translated == %Geo.Point{
               coordinates: {-73.84279077386554, 39.0},
               properties: %{name: "foo"}
             }
    end

    test "translating a multipoint" do
      geo = %Geo.MultiPoint{
        coordinates: [{-75, 39}, {-74, 36}, {-73, 38}],
        properties: %{name: "foo"}
      }

      translated = Landmark.Transformation.translate(geo, 100, 90)

      assert translated == %Geo.MultiPoint{
               coordinates: [
                 {-73.84279077386554, 39.0},
                 {-72.88837875730168, 36.0},
                 {-71.85874593394195, 38.0}
               ],
               properties: %{name: "foo"}
             }
    end

    test "translating a line string" do
      geo = %Geo.LineString{coordinates: [{-75, 39}, {-74, 36}], properties: %{name: "foo"}}

      translated = Landmark.Transformation.translate(geo, 100, 90)

      assert translated == %Geo.LineString{
               coordinates: [
                 {-73.84279077386554, 39.0},
                 {-72.88837875730168, 36.0}
               ],
               properties: %{name: "foo"}
             }
    end

    test "translating a polygon" do
      geo = %Geo.Polygon{
        coordinates: [[{-75, 39}, {-74, 36}, {-73, 38}, {-75, 39}]],
        properties: %{name: "foo"}
      }

      translated = Landmark.Transformation.translate(geo, 100, 90)

      assert translated == %Geo.Polygon{
               coordinates: [
                 [
                   {-73.84279077386554, 39.0},
                   {-72.88837875730168, 36.0},
                   {-71.85874593394195, 38.0},
                   {-73.84279077386554, 39.0}
                 ]
               ],
               properties: %{name: "foo"}
             }
    end
  end
end
