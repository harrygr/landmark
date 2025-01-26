defmodule Landmark.Helpers do
  @earth_radius_in_meters 6_371_008.0

  @type length_unit() :: :radians | :meters | :metres | :kilometers | :kilometres

  @spec earth_radius_in_meters() :: float()
  def earth_radius_in_meters(), do: @earth_radius_in_meters

  @doc """
  Convert a distance measurement (assuming a spherical Earth) from radians to a more friendly unit.

  ## Examples

      iex> Landmark.Helpers.radians_to_length(1, :kilometers)
      6371.008
  """
  @spec radians_to_length(number(), length_unit()) :: number()
  def radians_to_length(radians, unit)
  def radians_to_length(radians, :radians), do: radians
  def radians_to_length(radians, :meters), do: radians * @earth_radius_in_meters
  def radians_to_length(radians, :metres), do: radians_to_length(radians, :meters)
  def radians_to_length(radians, :kilometers), do: radians * @earth_radius_in_meters / 1_000
  def radians_to_length(radians, :kilometres), do: radians_to_length(radians, :kilometers)

  @doc """
  Convert a `length` measurement in the given `unit` to radians (assuming a spherical earth).

  ## Examples

      iex> Landmark.Helpers.length_to_radians(1000, :kilometers)
      0.15696103348167198
  """
  @spec length_to_radians(number(), length_unit()) :: number()
  def length_to_radians(length, unit)
  def length_to_radians(length, :radians), do: length
  def length_to_radians(length, :meters), do: length / @earth_radius_in_meters
  def length_to_radians(length, :metres), do: radians_to_length(length, :meters)
  def length_to_radians(length, :kilometers), do: length * 1000 / @earth_radius_in_meters
  def length_to_radians(length, :kilometres), do: radians_to_length(length, :kilometers)

  @doc """
  Convert a `length` from `from` unit to `to`

  ## Examples

      iex> Landmark.Helpers.convert_length(4500, :meters, :kilometers)
      4.5

      iex> Landmark.Helpers.convert_length(4500, :kilometers, :radians)
      0.7063246506675239

      iex> Landmark.Helpers.convert_length(35, :meters, :meters)
      35
  """
  @spec convert_length(number(), length_unit(), length_unit()) :: number()
  def convert_length(length, from, to)
  def convert_length(length, unit, unit), do: length

  def convert_length(length, from, to) do
    length
    |> length_to_radians(from)
    |> radians_to_length(to)
  end

  @doc """
  Get the coordinates from a GeoJSON object.

  ## Examples
      iex> Landmark.Helpers.coords(%Geo.Point{coordinates: {1, 2}})
      [{1, 2}]
      iex> Landmark.Helpers.coords(%Geo.MultiPoint{coordinates: [{1, 2}, {3, 4}]})
      [{1, 2}, {3, 4}]
      iex> Landmark.Helpers.coords(%Geo.Polygon{coordinates: [[{1, 2}, {3, 4}, {5, 6}], [{7, 8}, {9, 10}]]})
      [{1, 2}, {3, 4}, {5, 6}, {7, 8}, {9, 10}]
  """
  def coords(geojson)
  def coords(%Geo.Point{coordinates: coordinates}), do: [coordinates]
  def coords(%Geo.MultiPoint{coordinates: coordinates}), do: coordinates
  def coords(%Geo.LineString{coordinates: coordinates}), do: coordinates
  def coords(%Geo.MultiLineString{coordinates: coordinates}), do: List.flatten(coordinates)
  def coords(%Geo.Polygon{coordinates: coordinates}), do: List.flatten(coordinates)
end
