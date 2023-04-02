defmodule AbaValidator do
  import __MODULE__.Utils

  @moduledoc """
  Documentation for `AbaValidator`.
  """

  @doc """
  Get the entries as part of the descriptiive record

  ## Examples

      iex> AbaValidator.get_descriptive_record(1)
      {:error, :invalid_input}

      iex> AbaValidator.get_descriptive_record("11")
      {:error, :incorrect_length}

      iex> AbaValidator.get_descriptive_record("01")
      {:error, :incorrect_length}

      iex> AbaValidator.get_descriptive_record("1                 01CBA       test                      301500221212121227121222                                        ")
      {:error, :incorrect_starting_code}

      iex> AbaValidator.get_descriptive_record("0                   CBA       test                      301500221212121227121222                                        ")
      {:error, :invalid_format, [:reel_sequence_number]}

      iex> AbaValidator.get_descriptive_record("0                 01CBA       test                      301500221212121227121222                                        ")
      {:ok, {"01", "CBA", "test                      ", "301500", "221212121227", "121222"}}

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
            {:ok, {reel_sequence_number, bank_abbreviation, user_preferred_specification,
             user_id_number, description, date}}
          end
        end
      end
    end
  end

  @doc """
  Get the entries as part of the file total record

  ## Examples

      iex> AbaValidator.get_file_total_record(1)
      {:error, :invalid_input}

      iex> AbaValidator.get_file_total_record("11")
      {:error, :incorrect_length}

      iex> AbaValidator.get_file_total_record("01")
      {:error, :incorrect_length}

      iex> AbaValidator.get_file_total_record("1                 01CBA       test                      301500221212121227121222                                        ")
      {:error, :incorrect_starting_code}

      iex> AbaValidator.get_file_total_record("7999 999            000000000000000353890000035388                        000000                                        ")
      {:error, :invalid_format, [:bsb_filler, :net_total_mismatch ]}

      iex> AbaValidator.get_file_total_record("7                                                                                                                       ")
      {:error, :invalid_format, [:bsb_filler, :net_total, :total_credit, :total_debit, :record_count]}

      iex> AbaValidator.get_file_total_record("7999 999            000000000000000353890000035388                        000002                                        ")
      {:error, :invalid_format, [:bsb_filler, :net_total_mismatch, :records_mismatch]}

      iex> AbaValidator.get_file_total_record("7999-999            000000000000000353890000035389                        000000                                        ")
      {:ok, {0, 35389, 35389, 0}}

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

        # TODO Validate amount is positve
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

        # TODO Validate total amount from detail match debit/credit
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
          {:ok, {String.to_integer(net_total), String.to_integer(total_credit),
           String.to_integer(total_debit), String.to_integer(record_count)}}
        end
      end
    end
  end

  @doc """
  Get the entries as part of the detail record

  ## Examples

      iex> AbaValidator.get_detail_record(1)
      {:error, :invalid_input}

      iex> AbaValidator.get_detail_record("11")
      {:error, :incorrect_length}

      iex> AbaValidator.get_detail_record("01")
      {:error, :incorrect_length}

      iex> AbaValidator.get_detail_record("1032 898 12345678 130000035389money                           Batch payment     040 404 12345678test            00000000")
      {:error, :invalid_format, [:bsb,:trace_record]}

      iex> AbaValidator.get_detail_record("1                                                                                                                       ")
      {:error, :invalid_format,
               [:bsb, :account_number, :transasction_code, :amount, :account_name, :reference, :trace_record, :trace_account_number, :remitter, :withheld_tax]}

      iex> AbaValidator.get_detail_record("7999 999            000000000000000353890000035388                        000002                                        ")
      {:error, :incorrect_starting_code}

      iex> AbaValidator.get_detail_record("1032-898 12345678 130000035389 money                           Batch payment    040-404 12345678 test           00000000")
      {:ok, {"032-898", "12345678", :blank, :externally_initiated_debit, 35389, " money", " Batch payment","040-404", "12345678", " test", 0}}

      iex> AbaValidator.get_detail_record("1032-8980-2345678N130000035389money                           Batch payment     040-404 12345678test            00000000")
      {:ok, {"032-898", "0-2345678", :new_bank, :externally_initiated_debit, 35389, "money", "Batch payment","040-404", "12345678", "test", 0}}

  """
  def get_detail_record(entry) when not is_binary(entry) do
    {:error, :invalid_input}
  end

  def get_detail_record(entry) do
    if not correct_length?(entry, 120) do
      {:error, :incorrect_length}
    else
      {code, entry} = String.split_at(entry, 1)

      if code != "1" do
        {:error, :incorrect_starting_code}
      else
        {bsb, entry} = String.split_at(entry, 7)
        {account_number, entry} = String.split_at(entry, 9)
        {indicator, entry} = String.split_at(entry, 1)
        {transasction_code, entry} = String.split_at(entry, 2)
        {amount, entry} = String.split_at(entry, 10)
        {account_name, entry} = String.split_at(entry, 32)
        {reference, entry} = String.split_at(entry, 18)
        {trace_record, entry} = String.split_at(entry, 7)
        {trace_account_number, entry} = String.split_at(entry, 9)
        {remitter_name, withheld_tax} = String.split_at(entry, 16)

        reference = String.trim_trailing(reference)
        trace_account_number = String.trim_leading(trace_account_number)
        remitter_name = String.trim_trailing(remitter_name)
        account_number = String.trim_leading(account_number)
        account_name = String.trim_trailing(account_name)
        errors = []

        errors = if not valid_bsb?(bsb), do: errors ++ [:bsb], else: errors
        errors = if string_empty?(account_number), do: errors ++ [:account_number], else: errors

        errors =
          if get_indicator_code(indicator) == :error, do: errors ++ [:indicator], else: errors

        errors =
          if get_transaction_code(transasction_code) == :error,
            do: errors ++ [:transasction_code],
            else: errors

        errors = if Integer.parse(amount) == :error, do: errors ++ [:amount], else: errors
        errors = if string_empty?(account_name), do: errors ++ [:account_name], else: errors
        errors = if string_empty?(reference), do: errors ++ [:reference], else: errors
        errors = if not valid_bsb?(trace_record), do: errors ++ [:trace_record], else: errors

        errors =
          if string_empty?(trace_account_number),
            do: errors ++ [:trace_account_number],
            else: errors

        errors = if string_empty?(remitter_name), do: errors ++ [:remitter], else: errors

        errors =
          if Integer.parse(withheld_tax) == :error, do: errors ++ [:withheld_tax], else: errors

        if(length(errors) > 0) do
          {:error, :invalid_format, errors}
        else
          {:ok, {bsb, account_number, get_indicator_code(indicator),
           get_transaction_code(transasction_code), String.to_integer(amount), account_name,
           reference, trace_record, trace_account_number, remitter_name,
           String.to_integer(withheld_tax)}}
        end
      end
    end
  end

  defp get_transaction_code("13"), do: :externally_initiated_debit

  defp get_transaction_code("50"),
    do: :externally_initiated_credit

  defp get_transaction_code("51"), do: :australian_government_security_interest
  defp get_transaction_code("52"), do: :family_allowance
  defp get_transaction_code("53"), do: :pay
  defp get_transaction_code("54"), do: :pension
  defp get_transaction_code("55"), do: :allotment
  defp get_transaction_code("56"), do: :dividend
  defp get_transaction_code("57"), do: :debenture_note_interest
  defp get_transaction_code(_), do: :error

  defp get_indicator_code("N"), do: :new_bank
  defp get_indicator_code("W"), do: :dividend_resident_country_double_tax
  defp get_indicator_code("X"), do: :dividend_non_resident
  defp get_indicator_code("Y"), do: :interest_non_residents
  defp get_indicator_code(" "), do: :blank
  defp get_indicator_code(_), do: :error

  @spec get_transaction_code_description(String.t() | integer() | atom()) :: :error | String.t()
  @doc """
  Get a description for a given transaction code. See [here](https://www.cemtexaba.com/aba-format/cemtex-aba-file-format-details) for the possible transaction code

  The following atoms are valid inputs:
    - :allotment
    - :australian_government_security_interest
    - :debenture_note_interest
    - :dividend
    - :error
    - :externally_initiated_credit
    - :externally_initiated_debit
    - :family_allowance
    - :pay
    - :pension

  ## Examples

      iex> AbaValidator.get_transaction_code_description("11")
      :error

      iex> AbaValidator.get_transaction_code_description(53)
      "Pay"

      iex> AbaValidator.get_transaction_code_description(:australian_government_security_interest)
      "Australian Government Security Interest"

  """
  def get_transaction_code_description(13), do: "Externally initiated debit items"
  def get_transaction_code_description("13"), do: "Externally initiated debit items"

  def get_transaction_code_description(:externally_initiated_debit),
    do: "Externally initiated debit items"

  def get_transaction_code_description(50),
    do: "Externally initiated credit items with the exception of those bearing Transaction Codes"

  def get_transaction_code_description("50"),
    do: "Externally initiated credit items with the exception of those bearing Transaction Codes"

  def get_transaction_code_description(:externally_initiated_credit),
    do: "Externally initiated credit items with the exception of those bearing Transaction Codes"

  def get_transaction_code_description(51), do: "Australian Government Security Interest"
  def get_transaction_code_description("51"), do: "Australian Government Security Interest"

  def get_transaction_code_description(:australian_government_security_interest),
    do: "Australian Government Security Interest"

  def get_transaction_code_description(52), do: "Family Allowance"
  def get_transaction_code_description("52"), do: "Family Allowance"
  def get_transaction_code_description(:family_allowance), do: "Family Allowance"

  def get_transaction_code_description(53), do: "Pay"
  def get_transaction_code_description("53"), do: "Pay"
  def get_transaction_code_description(:pay), do: "Pay"

  def get_transaction_code_description(54), do: "Pension"
  def get_transaction_code_description("54"), do: "Pension"
  def get_transaction_code_description(:pension), do: "Pension"

  def get_transaction_code_description(55), do: "Allotment"
  def get_transaction_code_description("55"), do: "Allotment"
  def get_transaction_code_description(:allotment), do: "Allotment"

  def get_transaction_code_description(56), do: "Dividend"
  def get_transaction_code_description("56"), do: "Dividend"
  def get_transaction_code_description(:dividend), do: "Dividend"

  def get_transaction_code_description(57), do: "Debenture/Note Interest"
  def get_transaction_code_description("57"), do: "Debenture/Note Interest"
  def get_transaction_code_description(:debenture_note_interest), do: "Debenture/Note Interest"

  def get_transaction_code_description(_), do: :error
end
