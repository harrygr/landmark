defmodule Landmark.Helpers do
  @earth_radius 6_371_008.8

  @type length_unit() :: :radians | :meters | :metres | :kilometers | :kilometres

  @doc """
  Convert a distance measurement (assuming a spherical Earth) from radians to a more friendly unit.

  ## Examples

      iex> Landmark.Helpers.radians_to_length(1, :kilometers)
      6371.0088
  """
  @spec radians_to_length(number(), length_unit()) :: number()
  def radians_to_length(radians, unit)
  def radians_to_length(radians, :radians), do: radians
  def radians_to_length(radians, :meters), do: radians * @earth_radius
  def radians_to_length(radians, :metres), do: radians_to_length(radians, :meters)
  def radians_to_length(radians, :kilometers), do: radians * @earth_radius / 1000
  def radians_to_length(radians, :kilometres), do: radians_to_length(radians, :kilometers)
end
