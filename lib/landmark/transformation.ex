defmodule Landmark.Transformation do
  alias Landmark.Measurement

  @doc """
  Moves a geometry a specified distance along a Rhumb Line in the direction of the provided bearing

  ## Examples

      iex> Landmark.Transformation.translate(%Geo.Point{coordinates: {-75, 39}}, 100, 90)
      %Geo.Point{coordinates: {-73.84279077386554, 39.0}}

  """
  def translate(geometry, distance, bearing, options \\ [unit: :kilometers])

  def translate(%Geo.Point{properties: properties} = point, distance, bearing, options) do
    Measurement.rhumb_destination(point, distance, bearing, options)
    |> Map.put(:properties, properties)
  end

  def translate(
        %Geo.MultiPoint{coordinates: coordinates, properties: properties},
        distance,
        bearing,
        options
      ) do
    %Geo.MultiPoint{
      coordinates: translate_coordinates(coordinates, distance, bearing, options),
      properties: properties
    }
  end

  def translate(
        %Geo.LineString{coordinates: coordinates, properties: properties},
        distance,
        bearing,
        options
      ) do
    %Geo.LineString{
      coordinates: translate_coordinates(coordinates, distance, bearing, options),
      properties: properties
    }
  end

  def translate(
        %Geo.Polygon{coordinates: coordinates, properties: properties},
        distance,
        bearing,
        options
      ) do
    %Geo.Polygon{
      coordinates:
        coordinates
        |> Enum.map(fn subcoords ->
          translate_coordinates(subcoords, distance, bearing, options)
        end),
      properties: properties
    }
  end

  defp translate_coordinates(coordinates, distance, bearing, options) do
    coordinates
    |> Stream.map(
      &Measurement.rhumb_destination(%Geo.Point{coordinates: &1}, distance, bearing, options)
    )
    |> Enum.map(&Map.get(&1, :coordinates))
  end
end
