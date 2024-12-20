defmodule Landmark.Conversion do
  @doc """
  Takes a bbox and returns an equivalent polygon.

  ## Examples

      iex> Landmark.Conversion.bbox_polygon({0, 0, 10, 10})
      %Geo.Polygon{coordinates: [[{0, 0}, {10, 0}, {10, 10}, {0, 10}, {0, 0}]]}
  """
  @spec bbox_polygon(Landmark.bbox()) :: Geo.Polygon.t()
  def bbox_polygon({w, s, e, n}) do
    bottom_left = {w, s}
    top_left = {w, n}
    top_right = {e, n}
    bottom_right = {e, s}

    %Geo.Polygon{coordinates: [[bottom_left, bottom_right, top_right, top_left, bottom_left]]}
  end
end
