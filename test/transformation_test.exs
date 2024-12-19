defmodule TransformationTest do
  use ExUnit.Case

  describe "translate" do
    test "translating a point" do
      geo = %Geo.Point{coordinates: {-75, 39}}

      translated = Landmark.Transformation.transform(geo, 100, 90)

      assert translated == %Geo.Point{coordinates: {-73.84279077386554, 39.0}}
    end

    test "translating a line string" do
      geo = %Geo.LineString{coordinates: [{-75, 39}, {-74, 36}]}

      translated = Landmark.Transformation.transform(geo, 100, 90)

      assert translated == %Geo.LineString{
               coordinates: [{-73.84279077386554, 39.0}, {-72.88837875730168, 36.0}]
             }
    end
  end
end
