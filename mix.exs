defmodule Dumpster.MixProject do
  use Mix.Project

  def project do
    [
      app: :dumpster,
      version: "0.2.0",
      elixir: "~> 1.6",
      build_embedded: Mix.env() == :prod,
      start_permanent: Mix.env() == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "dumpster",
      source_url: "https://github.com/elridion/dumpster"
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
      {:credo, "~> 0.10.0", only: :dev},
      {:ex_doc, "~> 0.19", only: :dev}
    ]
  end

  defp description() do
    "Simple and easy to use binary-dumps."
  end

  defp package() do
    [
      maintainers: ["Hans Bernhard Goedeke"],
      files: ~w(lib .formatter.exs mix.exs README* LICENSE*),
      licenses: ["MIT License"],
      links: %{"GitHub" => "https://github.com/elridion/dumpster"}
    ]
  end
end
