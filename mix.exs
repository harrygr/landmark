defmodule Landmark.MixProject do
  use Mix.Project

  def project do
    [
      app: :landmark,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      description: description(),
      package: package()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:geo, "~> 3.1 or ~> 4.0"},
      {:math, "~> 0.6.0"},
      {:ex_doc, ">= 0.0.0", only: :dev, runtime: false}
    ]
  end

  defp description do
    """
    A geospatial analysis library for Elixir
    """
  end

  defp package do
    [
      files: ["lib/landmark.ex", "lib/landmark", "mix.exs", "README*"],
      maintainers: ["Harry Grumbar"],
      licenses: ["MIT"],
      links: %{"GitHub" => "https://github.com/harrygr/landmark"}
    ]
  end
end
