defmodule Landmark.Measurement do
  alias Landmark.Helpers
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
  @spec centroid(Geo.geometry() | Enumerable.t(Landmark.lng_lat())) :: Geo.Point.t()
  def centroid(object)
  def centroid(%Geo.Point{} = p), do: p

  def centroid(%Geo.Polygon{coordinates: coordinates}) do
    coordinates
    # drop the head of each set of points as they should contain
    # a wrapping point to bring it back to the start
    |> Stream.flat_map(fn [_ | points] -> points end)
    |> centroid()
  end

  def centroid(%Geo.LineString{coordinates: coordinates}), do: centroid(coordinates)
  def centroid(%Geo.MultiPoint{coordinates: coordinates}), do: centroid(coordinates)

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

  @doc """
  Computes the bounding box for an object.

  ## Examples
      iex> Landmark.Measurement.bbox(%Geo.LineString{coordinates: [{1, 2}, {4, 6}]})
      {1, 2, 4, 6}

      iex> Landmark.Measurement.bbox(%Geo.LineString{coordinates: []})
      nil
  """
  @spec bbox(Geo.geometry() | Enumerable.t(Landmark.lng_lat())) ::
          Landmark.bbox() | nil
  def bbox(object)

  def bbox(%Geo.Point{coordinates: coordinates}), do: bbox([coordinates])
  def bbox(%Geo.LineString{coordinates: coordinates}), do: bbox(coordinates)
  def bbox(%Geo.MultiPoint{coordinates: coordinates}), do: bbox(coordinates)

  def bbox(%Geo.Polygon{coordinates: coordinates}) do
    coordinates
    |> List.flatten()
    |> bbox()
  end

  def bbox(coordinates) do
    coordinates
    |> Enum.reduce(nil, fn
      {x, y}, nil -> {x, y, x, y}
      {x, y}, {x1, y1, x2, y2} -> {min(x, x1), min(y, y1), max(x, x2), max(y, y2)}
    end)
  end

  @doc """
  Given a start point, initial bearing, and distance, will calculate the destina­tion point
  from travelling along a (shortest distance) great circle arc.

  ## Examples

      iex> Landmark.Measurement.destination(%Geo.Point{coordinates: {-75, 39}}, 100, 90)
      %Geo.Point{coordinates: {-73.84285308264721, 38.99428496242162}}
  """
  @spec destination(Geo.Point.t(), number(), number(), keyword()) :: Geo.Point.t()
  def destination(origin, distance, bearing, options \\ [unit: :kilometers])

  def destination(
        %Geo.Point{coordinates: {lon, lat}},
        distance,
        bearing,
        options
      ) do
    distance_unit = Keyword.get(options, :unit)

    lon_1 = Math.deg2rad(lon)
    lat_1 = Math.deg2rad(lat)
    distance_radians = Helpers.length_to_radians(distance, distance_unit)
    bearing_radians = Math.deg2rad(bearing)

    lat_2 =
      Math.asin(
        Math.sin(lat_1) * Math.cos(distance_radians) +
          Math.cos(lat_1) * Math.sin(distance_radians) * Math.cos(bearing_radians)
      )

    lon_2 =
      lon_1 +
        Math.atan2(
          Math.sin(bearing_radians) * Math.sin(distance_radians) * Math.cos(lat_1),
          Math.cos(distance_radians) - Math.sin(lat_1) * Math.sin(lat_2)
        )

    %Geo.Point{coordinates: {Math.rad2deg(lon_2), Math.rad2deg(lat_2)}}
  end

  @doc """
  Returns the destination point having travelled along a rhumb line from
  the origin point the given distance on the given bearing.

  See http://www.movable-type.co.uk/scripts/latlong.html#rhumblines
  """
  def rhumb_destination(origin, distance, bearing, options \\ [unit: :kilometers])

  def rhumb_destination(%Geo.Point{coordinates: coordinates}, distance, bearing, options) do
    %Geo.Point{coordinates: calculate_rhumb_destination(coordinates, distance, bearing, options)}
  end

  defp calculate_rhumb_destination({lon, lat}, distance, bearing, options) do
    distance_unit = Keyword.get(options, :unit)

    distance_in_meters = Landmark.Helpers.convert_length(distance, distance_unit, :meters)
    earth_radius = Landmark.Helpers.earth_radius_in_meters()

    delta = distance_in_meters / earth_radius

    theta = Math.deg2rad(bearing)

    phi_1 = Math.deg2rad(lat)

    lambda_1 = Math.deg2rad(lon)

    delta_phi = delta * Math.cos(theta)

    phi_2 =
      (phi_1 + delta_phi)
      |> then(fn p2 ->
        # check for some daft bugger going past the pole, normalise latitude if so
        cond do
          abs(p2) > Math.pi() / 2 -> if p2 > 0, do: Math.pi() - p2, else: -Math.pi() - p2
          true -> p2
        end
      end)

    delta_psi =
      Math.log(Math.tan(phi_2 / 2 + Math.pi() / 4) / Math.tan(phi_1 / 2 + Math.pi() / 4))

    q = if abs(delta_psi) > 10.0e-12, do: delta_phi / delta_psi, else: Math.cos(phi_1)

    delta_lambda = delta * Math.sin(theta) / q

    lambda_2 = lambda_1 + delta_lambda

    {Math.rad2deg(lambda_2), Math.rad2deg(phi_2)}
  end
end
