defmodule FpLab2.MixProject do
  @moduledoc """
  Settings for fp_lab2 mix project.
  """

  use Mix.Project

  @version "version" |> File.read!() |> String.trim()

  def project do
    [
      app: :fp_lab2,
      elixir: "~> 1.17",
      elixirc_paths: elixirc_paths(Mix.env()),
      preferred_cli_env: [
        # Test coverage
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test,
        "coveralls.cobertura": :test
      ],
      test_coverage: [tool: ExCoveralls],
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      aliases: aliases(),

      # Docs
      name: "functional-programming-2",
      source_url: "https://github.com/maxbarsukov-itmo/functional-programming-2",
      homepage_url: "https://github.com/maxbarsukov-itmo/functional-programming-2",

      # Hex
      description: description(),
      package: package(),
      version: @version
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  defp deps do
    [
      # Test coverage
      {:excoveralls, "~> 0.18", only: :test},

      # Linting & formatting
      {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
      {:dialyxir, "~> 1.4", only: [:dev, :test], runtime: false},
      {:ex_check, "~> 0.16.0", only: [:dev], runtime: false}
    ]
  end

  def aliases do
    []
  end

  def description do
    "RedBlack Tree on Set realization in Elixir"
  end

  def package do
    [
      files: ["lib", "mix.exs", "LICENSE*", "README*", "version"],
      licenses: ["MIT"],
      links: %{
        "GitHub" => "https://github.com/maxbarsukov-itmo/functional-programming-2"
      },
      maintainers: ["Max Barsukov <maximbarsukov@bk.ru>"]
    ]
  end
end
