defmodule AbaFileValidator do
  import __MODULE__.Utils, only: [correct_length?: 1]
  @moduledoc """
  Documentation for `AbaFileValidator`.
  """

  @doc """
  Validates the entry as a descriptive record

  ## Examples

      iex> AbaFileValidator.validate_descriptive_record(1)
      {:error, :invalid_input}

      iex> AbaFileValidator.validate_descriptive_record("11")
      {:error, :incorrect_length}

      iex> AbaFileValidator.validate_descriptive_record("1                 01CBA       test                      301500221212121227121222                                        ")
      {:error, :incorrect_starting_code}

      iex> AbaFileValidator.validate_descriptive_record("0                 01CBA       test                      301500221212121227121222                                        ")
      :ok

  """

  def validate_descriptive_record(entry) when is_binary(entry) do
    if not correct_length?(entry) do
      {:error, :incorrect_length}
    else
      correct_descriptive_record?(entry)
    end
  end

  def validate_descriptive_record(_) do
    {:error, :invalid_input}
  end

  defp correct_descriptive_record?("0"<>entry) do
    :ok
  end

  defp correct_descriptive_record?(_) do
    {:error, :incorrect_starting_code}
  end







  @doc """
  Get a description for a given transaction code

  ## Examples

      iex> AbaFileValidator.get_transaction_code_description("11")
      :error

      iex> AbaFileValidator.get_transaction_code_description(13)
      "Externally initiated debit items"

  """
  def get_transaction_code_description(13), do: "Externally initiated debit items"
  def get_transaction_code_description("13"), do: "Externally initiated debit items"

  def get_transaction_code_description(50),
    do: "Externally initiated credit items with the exception of those bearing Transaction Codes"

  def get_transaction_code_description("50"),
    do: "Externally initiated credit items with the exception of those bearing Transaction Codes"

  def get_transaction_code_description(51), do: "Australian Government Security Interest"
  def get_transaction_code_description("51"), do: "Australian Government Security Interest"
  def get_transaction_code_description(52), do: "Family Allowance"
  def get_transaction_code_description("52"), do: "Family Allowance"
  def get_transaction_code_description(53), do: "Pay"
  def get_transaction_code_description("53"), do: "Pay"
  def get_transaction_code_description(54), do: "Pension"
  def get_transaction_code_description("54"), do: "Pension"
  def get_transaction_code_description(55), do: "Allotment"
  def get_transaction_code_description("55"), do: "Allotment"
  def get_transaction_code_description(56), do: "Dividend"
  def get_transaction_code_description("56"), do: "Dividend"
  def get_transaction_code_description(57), do: "Debenture/Note Interest"
  def get_transaction_code_description("57"), do: "Debenture/Note Interest"
  def get_transaction_code_description(_), do: :error
end
