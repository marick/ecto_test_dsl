defmodule EctoTestDSL.MixProject do
  use Mix.Project

  @github "https://github.com/marick/ecto_test_dsl"
  @version "0.1.0"

  def project do
    [
      description: """
      Provides support for testing code that transforms input, validates it,
      and fills one or more structures. The most natural use is for tests that
      supply HTTP data to code that creates Ecto schema structures. Handles 
      both test data creation and result checking (more tersely and clearly than
      writing your own assertions). 
      """,
      
      app: :ecto_test_dsl,
      version: @version,
      elixir: "~> 1.10",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),

      # Docs
      name: "Ecto Test DSL",
      source_url: @github,
      docs: [
        main: "readme",
        extras: ~w/README.md/,
      ],
      
      package: [
        contributors: ["marick@exampler.com"],
        maintainers: ["marick@exampler.com"],
        licenses: ["Unlicense"],
        links: %{
          "GitHub" => @github
        },
      ]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test),
    do: ["lib", "test/support", "examples", "test/integration"
        ]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_doc, "~> 0.22", only: :dev, runtime: false},
      {:flow_assertions, "~> 0.7",
       path: "/Users/bem/src/flow_assertions",
       override: true
      },
      {:ecto_flow_assertions, "~> 0.1"},
      #  path: "/Users/bem/src/ecto_flow_assertions"
      # },
###      {:ecto, "~> 3.0"},
      {:ecto_sql, "~> 3.4"},      
      {:deep_merge, "~> 1.0"},      
      {:ex_machina, "~> 2.3", only: :test},
      {:magritte, "~> 0.1.2"},
      {:mockery_extras, "~> 0.2"},
      {:ex_contract, "~> 0.1.1"},
      {:shorter_maps, "~> 2.2"}
      
      # {:dep_from_hexpm, "~> 0.3.0"},
      # {:dep_from_git, git: "https://github.com/elixir-lang/my_dep.git", tag: "0.1.0"}
    ]
  end
end
