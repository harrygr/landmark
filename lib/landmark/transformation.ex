defmodule Landmark.Transformation do
  alias Landmark.Measurement

  @doc """
  Moves a geometry a specified distance along a Rhumb Line in the direction of the provided bearing
  """
  def transform(geometry, distance, bearing, options \\ [unit: :kilometers])

  def transform(%Geo.Point{} = point, distance, bearing, options) do
    Measurement.rhumb_destination(point, distance, bearing, options)
  end

  def transform(%Geo.LineString{coordinates: coordinates}, distance, bearing, options) do
    %Geo.LineString{
      coordinates:
        Enum.map(
          coordinates,
          &Measurement.calculate_rhumb_destination(&1, distance, bearing, options)
        )
    }
  end
end
