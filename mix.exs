defmodule App.MixProject do
  use Mix.Project

  def project do
    [
      app: :app,
      version: "0.1.0",
      elixir: "~> 1.16",
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      releases: releases()
    ]
  end

  defp releases do
    [
      app: [
        include_executables_for: [:unix]
      ]
    ]
  end

  def application do
    [
      mod: {App.Application, []},
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:plug, "~> 1.20.3"},
      {:bandit, "~> 1.12.4"}
    ]
  end
end
