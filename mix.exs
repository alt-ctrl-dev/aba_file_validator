defmodule AbaValidator.MixProject do
  use Mix.Project

  @github_link "https://github.com/alt-ctrl-dev/aba_validator"

  def project do
    [
      app: :aba_validator,
      version: "1.0.0",
      elixir: "~> 1.0",
      build_embedded: Mix.env == :prod,
      start_permanent: Mix.env == :prod,
      description: description(),
      package: package(),
      deps: deps(),
      name: "ABA Validator",
      source_url: @github_link,
      docs: [
        main: "Aba Validator", # The main page in the docs
        extras: ["README.md"]
      ]
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
      {:ex_doc, "~> 0.14", only: :dev, runtime: false}
    ]
  end

  defp description() do
    "an Elixir library to validate an Australian Banking Association (ABA) file"
  end

  defp package() do
    [
      # This option is only needed when you don't want to use the OTP application name
      name: "aba_validator",
      # These are the default files included in the package
      files: ~w(lib priv .formatter.exs mix.exs README* readme* LICENSE*
                license* CHANGELOG* changelog* src),
      licenses: ["Apache-2.0"],
      links: %{"GitHub" => @github_link}
    ]
  end
end
