defmodule ExBot.MixProject do
  use Mix.Project

  def project do
    [
      app: :ex_bot,
      version: "0.1.0",
      elixir: "~> 1.15",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {TradingApp, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:req, "~> 0.4.5"},
      {:jason, "~> 1.4"},
      {:gen_stage, "~> 1.2"},
      {:broadway, "~> 1.0"},
      {:ex_doc, "~> 0.30.9"}
    ]
  end
end
