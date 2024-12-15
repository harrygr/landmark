defmodule Landmark.Helpers do
  @earth_radius 6_371_008.8

  @doc """
  Convert a distance measurement (assuming a spherical Earth) from radians to a more friendly unit.
  """
  def radians_to_length(radians, unit)
  def radians_to_length(radians, :radians), do: radians
  def radians_to_length(radians, :meters), do: radians * @earth_radius
  def radians_to_length(radians, :metres), do: radians * @earth_radius
  def radians_to_length(radians, :kilometers), do: radians * @earth_radius / 1000
end
