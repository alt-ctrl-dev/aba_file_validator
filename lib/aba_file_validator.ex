defmodule AbaFileValidator do
  import __MODULE__.Utils, only: [correct_length?: 2, string_empty?: 1, valid_date?: 1]

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

      iex> AbaFileValidator.validate_descriptive_record("0                   CBA       test                      301500221212121227121222                                        ")
      {:error, :invalid_format}

      iex> AbaFileValidator.validate_descriptive_record("0                 01CBA       test                      301500221212121227121222                                        ")
      :ok

  """

  def validate_descriptive_record(entry) when not is_binary(entry) do
    {:error, :invalid_input}
  end

  def validate_descriptive_record(entry) do
    if not correct_length?(entry, 120) do
      {:error, :incorrect_length}
    else
      get_descriptive_record?(entry)
      |> case do
        {:ok, _, _, _, _, _, _} -> :ok
        error -> error
      end
    end
  end

  def get_descriptive_record?("0" <> entry) do
    {first_blank, entry} = String.split_at(entry, 17)
    {reel_sequence_number, entry} = String.split_at(entry, 2)
    {bank_abbreviation, entry} = String.split_at(entry, 3)
    {mid_blank, entry} = String.split_at(entry, 7)
    {user_preferred_specification, entry} = String.split_at(entry, 26)
    {user_id_number, entry} = String.split_at(entry, 6)
    {description, entry} = String.split_at(entry, 12)
    {date, last_blank} = String.split_at(entry, 6)

    with true <- correct_length?(first_blank, 17),
         true <- correct_length?(mid_blank, 7),
         true <- correct_length?(last_blank, 40),
         false <- string_empty?(reel_sequence_number),
         false <- string_empty?(bank_abbreviation),
         false <- string_empty?(user_preferred_specification),
         false <- string_empty?(user_id_number),
         false <- string_empty?(description),
         true <- valid_date?(date),
         false <- string_empty?(date) do
      {:ok, reel_sequence_number, bank_abbreviation, user_preferred_specification, user_id_number,
       description, date}
    else
      error ->
        IO.inspect(error, label: :error)
        {:error, :invalid_format}
    end
  end

  def get_descriptive_record?(_) do
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
