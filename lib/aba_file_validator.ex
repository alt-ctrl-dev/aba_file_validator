defmodule AbaFileValidator do
  import __MODULE__.Utils, only: [correct_length?: 2, string_empty?: 1, valid_date?: 1]

  @moduledoc """
  Documentation for `AbaFileValidator`.
  """

  @spec get_descriptive_record(String.t()) ::
          {:error, :incorrect_length | :incorrect_starting_code | :invalid_format}
          | {:ok, String.t(), String.t(), String.t(), String.t(), String.t(), String.t()}
  @doc """
  Get the entries as part of the descriptiive record

  ## Examples

      iex> AbaFileValidator.get_descriptive_record(1)
      {:error, :invalid_input}

      iex> AbaFileValidator.get_descriptive_record("11")
      {:error, :incorrect_length}

      iex> AbaFileValidator.get_descriptive_record("01")
      {:error, :incorrect_length}

      iex> AbaFileValidator.get_descriptive_record("1                 01CBA       test                      301500221212121227121222                                        ")
      {:error, :incorrect_starting_code}

      iex> AbaFileValidator.get_descriptive_record("0                   CBA       test                      301500221212121227121222                                        ")
      {:error, :invalid_format, [:reel_sequence_number]}

      iex> AbaFileValidator.get_descriptive_record("0                 01CBA       test                      301500221212121227121222                                        ")
      {:ok, "01", "CBA", "test                      ", "301500", "221212121227", "121222"}

  """
  def get_descriptive_record(entry) when not is_binary(entry) do
    {:error, :invalid_input}
  end

  def get_descriptive_record(entry) do
    if not correct_length?(entry, 120) do
      {:error, :incorrect_length}
    else
      {code, entry} = String.split_at(entry, 1)

      if code != "0" do
        {:error, :incorrect_starting_code}
      else
        {first_blank, entry} = String.split_at(entry, 17)
        {reel_sequence_number, entry} = String.split_at(entry, 2)
        {bank_abbreviation, entry} = String.split_at(entry, 3)
        {mid_blank, entry} = String.split_at(entry, 7)
        {user_preferred_specification, entry} = String.split_at(entry, 26)
        {user_id_number, entry} = String.split_at(entry, 6)
        {description, entry} = String.split_at(entry, 12)
        {date, last_blank} = String.split_at(entry, 6)

        with correct_first_blanks <- correct_length?(first_blank, 17),
             correct_mid_blanks <- correct_length?(mid_blank, 7),
             correct_last_blanks <- correct_length?(last_blank, 40),
             reel_sequence_number_empty? <- string_empty?(reel_sequence_number),
             bank_abbreviation_empty? <- string_empty?(bank_abbreviation),
             user_preferred_specification_empty? <- string_empty?(user_preferred_specification),
             user_id_number_empty? <- string_empty?(user_id_number),
             description_empty? <- string_empty?(description),
             valid_date <- valid_date?(date),
             date_empty? <- string_empty?(date) do
          errors = []

          errors = if not correct_first_blanks, do: errors ++ [:first_blank], else: errors

          errors = if not correct_last_blanks, do: errors ++ [:last_blank], else: errors

          errors = if not correct_mid_blanks, do: errors ++ [:mid_blank], else: errors

          errors =
            if reel_sequence_number_empty?, do: errors ++ [:reel_sequence_number], else: errors

          errors = if bank_abbreviation_empty?, do: errors ++ [:bank_abbreviation], else: errors

          errors =
            if user_preferred_specification_empty?,
              do: errors ++ [:user_preferred_specification],
              else: errors

          errors = if user_id_number_empty?, do: errors ++ [:user_id_number], else: errors

          errors = if description_empty?, do: errors ++ [:description], else: errors

          errors = if not valid_date or date_empty?, do: errors ++ [:date], else: errors

          if(length(errors) > 0) do
            {:error, :invalid_format, errors}
          else
            {:ok, reel_sequence_number, bank_abbreviation, user_preferred_specification,
             user_id_number, description, date}
          end
        end
      end
    end
  end

  @spec get_file_total_record(String.t(), integer()) ::
          {:error, :incorrect_length | :incorrect_starting_code | :invalid_input}
          | {:error, :invalid_format,
             [
               :bsb_filler
               | :first_blank
               | :last_blank
               | :mid_blank
               | :net_total
               | :net_total_mismatch
               | :record_count
               | :records_mismatch
               | :total_credit
               | :total_debit
             ]}
          | {:ok, integer(), integer(), integer(), integer()}
  @doc """
  Get the entries as part of the file total record

  ## Examples

      iex> AbaFileValidator.get_file_total_record(1)
      {:error, :invalid_input}

      iex> AbaFileValidator.get_file_total_record("11")
      {:error, :incorrect_length}

      iex> AbaFileValidator.get_file_total_record("01")
      {:error, :incorrect_length}

      iex> AbaFileValidator.get_file_total_record("1                 01CBA       test                      301500221212121227121222                                        ")
      {:error, :incorrect_starting_code}

      iex> AbaFileValidator.get_file_total_record("7999 999            000000000000000353890000035388                        000000                                        ")
      {:error, :invalid_format, [:bsb_filler, :net_total_mismatch ]}

      iex> AbaFileValidator.get_file_total_record("7                                                                                                                       ")
      {:error, :invalid_format, [:bsb_filler, :net_total, :total_credit, :total_debit, :record_count]}

      iex> AbaFileValidator.get_file_total_record("7999 999            000000000000000353890000035388                        000002                                        ")
      {:error, :invalid_format, [:bsb_filler, :net_total_mismatch, :records_mismatch]}

      iex> AbaFileValidator.get_file_total_record("7999-999            000000000000000353890000035389                        000000                                        ")
      {:ok, 0, 35389, 35389, 0}

  """
  def get_file_total_record(entry, records \\ 0)

  def get_file_total_record(entry, _records) when not is_binary(entry) do
    {:error, :invalid_input}
  end

  def get_file_total_record(entry, records) when is_number(records) do
    if not correct_length?(entry, 120) do
      {:error, :incorrect_length}
    else
      {code, entry} = String.split_at(entry, 1)

      if code != "7" do
        {:error, :incorrect_starting_code}
      else
        {bsb_filler, entry} = String.split_at(entry, 7)
        {first_blank, entry} = String.split_at(entry, 12)
        {net_total, entry} = String.split_at(entry, 10)
        {total_credit, entry} = String.split_at(entry, 10)
        {total_debit, entry} = String.split_at(entry, 10)
        {mid_blank, entry} = String.split_at(entry, 24)
        {record_count, last_blank} = String.split_at(entry, 6)

        errors = []

        errors = if bsb_filler !== "999-999", do: errors ++ [:bsb_filler], else: errors

        errors =
          if not correct_length?(first_blank, 12), do: errors ++ [:first_blank], else: errors

        errors = if not correct_length?(last_blank, 40), do: errors ++ [:last_blank], else: errors

        errors = if not correct_length?(mid_blank, 24), do: errors ++ [:mid_blank], else: errors

        errors = if string_empty?(net_total), do: errors ++ [:net_total], else: errors

        errors = if string_empty?(total_credit), do: errors ++ [:total_credit], else: errors

        errors =
          if string_empty?(total_debit),
            do: errors ++ [:total_debit],
            else: errors

        errors = if string_empty?(record_count), do: errors ++ [:record_count], else: errors

        errors =
          unless string_empty?(net_total) and string_empty?(total_credit) and
                   string_empty?(total_debit) do
            net_amount = String.to_integer(net_total)
            credit_amount = String.to_integer(total_credit)
            debit_amount = String.to_integer(total_debit)

            if net_amount !== credit_amount - debit_amount,
              do: errors ++ [:net_total_mismatch],
              else: errors
          else
            errors
          end

        errors =
          unless string_empty?(record_count) do
            if records !== String.to_integer(record_count),
              do: errors ++ [:records_mismatch],
              else: errors
          else
            errors
          end

        if(length(errors) > 0) do
          {:error, :invalid_format, errors}
        else
          {:ok, String.to_integer(net_total), String.to_integer(total_credit),
           String.to_integer(total_debit), String.to_integer(record_count)}
        end
      end
    end
  end

  @spec get_transaction_code_description(String.t()) :: :error | String.t()
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
