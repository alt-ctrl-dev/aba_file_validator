# ABA Validator
[![Unit tests](https://github.com/alt-ctrl-dev/aba_file_validator/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/alt-ctrl-dev/aba_file_validator/actions/workflows/ci.yml)

## Installation

If [available in Hex](https://hex.pm/docs/publish), the package can be installed
by adding `aba_validator` to your list of dependencies in `mix.exs`:

```elixir
def deps do
  [
    {:aba_validator, "~> 0.1.0"}
  ]
end
```

Documentation can be generated with [ExDoc](https://github.com/elixir-lang/ex_doc)
and published on [HexDocs](https://hexdocs.pm). Once published, the docs can
be found at <https://hexdocs.pm/aba_validator>.


## About
ABA File validator is an Elixir library to validate an Australian Banking Association (ABA) file.
An Australian Banking Association (ABA) file is a standard of file used by Australian Banks to make multiple payments for uploading data to Internet Banking systems. Read more [here](https://www.anz.com.au/support/internet-banking/getting-started/glossary/#aba_file)

## TODO
[] - more validation (currently the business logic is good enough, but it does not have dependent checks, e.g. if detail record has credits to Employee Benefits Card accounts, then Account Number field must always be 999999)