defmodule KQL.MixProject do
  use Mix.Project
  @version "0.1.0"
  @source_url "https://github.com/tvlabs-ai/kql"

  def project do
    [
      name: "KQL",
      app: :kql,
      aliases: aliases(),
      version: @version,
      elixir: "~> 1.18",
      deps: deps(),
      start_permanent: Mix.env() == :prod,
      description: "KQL (Kibana query language) parser",
      package: [
        licenses: ["Apache-2.0"],
        links: %{
          "GitHub" => @source_url,
          "Elastic Docs" => "https://www.elastic.co/docs/reference/query-languages/kql",
          "Changelog" => "https://github.com/tvlabs-ai/kql/blob/#{@version}/CHANGELOG.md"
        }
      ],
      docs: [
        source_ref: @version,
        source_url: @source_url,
        extras: ["CHANGELOG.md"]
      ]
    ]
  end

  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp deps do
    [
      {:nimble_parsec, "~> 1.4", only: [:dev, :test]},
      {:stream_data, "~> 1.1.1", only: [:test], runtime: false}
    ]
  end

  defp aliases do
    [
      "compile.nimble": ["nimble_parsec.compile lib/kql.ex.exs", "format lib/kql.ex"]
    ]
  end
end
