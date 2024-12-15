defmodule Landmark.Measurement do
  alias Geo.Point

  @doc """
  Takes two `Geo.Point`s and finds the geographic bearing between them,
  i.e. the angle measured in degrees from the north line (0 degrees)
  """
  def bearing(%Point{coordinates: {lon1, lat1}}, %Point{coordinates: {lon2, lat2}}) do
    lon1r = Math.deg2rad(lon1)
    lon2r = Math.deg2rad(lon2)
    lat1r = Math.deg2rad(lat1)
    lat2r = Math.deg2rad(lat2)

    a = Math.sin(lon2r - lon1r) * Math.cos(lat2r)

    b =
      Math.cos(lat1r) * Math.sin(lat2r) -
        Math.sin(lat1r) * Math.cos(lat2r) * Math.cos(lon2r - lon1r)

    Math.atan2(a, b) |> Math.rad2deg()
  end

  @doc """
  Calculates the distance between two coordinates.
  Uses the Haversine formula to account for global curvature.

  Default unit is kilometers.
  """
  def distance(from, to, unit \\ :kilometers)

  def distance(
        %Point{coordinates: {lon1, lat1}},
        %Point{coordinates: {lon2, lat2}},
        unit
      ) do
    d_lat = Math.deg2rad(lat2 - lat1)
    d_lon = Math.deg2rad(lon2 - lon1)
    lat1r = Math.deg2rad(lat1)
    lat2r = Math.deg2rad(lat2)

    a =
      Math.pow(Math.sin(d_lat / 2), 2) +
        Math.pow(Math.sin(d_lon / 2), 2) * Math.cos(lat1r) * Math.cos(lat2r)

    (2 * Math.atan2(Math.sqrt(a), Math.sqrt(1 - a)))
    |> Landmark.Helpers.radians_to_length(unit)
  end

  @doc """
  Computes the centroid as the mean of all vertices within the object.
  """
  def centroid(object)
  def centroid(%Geo.Point{} = p), do: p

  def centroid(%Geo.Polygon{coordinates: coordinates}) do
    coordinates
    # drop the head of each set of points as they should contain
    # a wrapping point to bring it back to the start
    |> Stream.flat_map(fn [_ | points] -> points end)
    |> centroid()
  end

  def centroid(%Geo.LineString{coordinates: coordinates}) do
    centroid(coordinates)
  end

  def centroid(coordinates) do
    coordinates
    |> Enum.reduce(
      %{x_sum: 0, y_sum: 0, len: 0},
      fn {x, y}, %{x_sum: x_sum, y_sum: y_sum, len: len} ->
        %{x_sum: x_sum + x, y_sum: y_sum + y, len: len + 1}
      end
    )
    |> then(fn %{x_sum: x_sum, y_sum: y_sum, len: len} ->
      %Geo.Point{coordinates: {x_sum / len, y_sum / len}}
    end)
  end
end
