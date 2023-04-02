defmodule AbaValidatorTest do
  use ExUnit.Case
  doctest AbaValidator

  test "AbaValidator.get_transaction_code_description/1" do
    assert AbaValidator.get_transaction_code_description(11) == :error

    assert AbaValidator.get_transaction_code_description(13) ==
             "Externally initiated debit items"

    assert AbaValidator.get_transaction_code_description("13") ==
             "Externally initiated debit items"

    assert AbaValidator.get_transaction_code_description(50) ==
             "Externally initiated credit items with the exception of those bearing Transaction Codes"

    assert AbaValidator.get_transaction_code_description("50") ==
             "Externally initiated credit items with the exception of those bearing Transaction Codes"

    assert AbaValidator.get_transaction_code_description(51) ==
             "Australian Government Security Interest"

    assert AbaValidator.get_transaction_code_description("51") ==
             "Australian Government Security Interest"

    assert AbaValidator.get_transaction_code_description(52) == "Family Allowance"
    assert AbaValidator.get_transaction_code_description("52") == "Family Allowance"
    assert AbaValidator.get_transaction_code_description(53) == "Pay"
    assert AbaValidator.get_transaction_code_description("53") == "Pay"
    assert AbaValidator.get_transaction_code_description(54) == "Pension"
    assert AbaValidator.get_transaction_code_description("54") == "Pension"
    assert AbaValidator.get_transaction_code_description(55) == "Allotment"
    assert AbaValidator.get_transaction_code_description("55") == "Allotment"
    assert AbaValidator.get_transaction_code_description(56) == "Dividend"
    assert AbaValidator.get_transaction_code_description("56") == "Dividend"
    assert AbaValidator.get_transaction_code_description(57) == "Debenture/Note Interest"
    assert AbaValidator.get_transaction_code_description("57") == "Debenture/Note Interest"
  end

  describe "AbaValidator.get_descriptive_record/1" do
    test "validates succesfully" do
      entry =
        "0                 01CBA       test                      301500221212121227121222                                        "

      assert AbaValidator.get_descriptive_record(entry) ==
               {:ok, {"01", "CBA", "test                      ", "301500", "221212121227",
                "121222"}}
    end

    test "returns an error if incorrect length with correct starting code" do
      assert AbaValidator.get_descriptive_record("0") == {:error, :incorrect_length}
    end

    test "returns an error if incorrect length with incorrect starting code" do
      assert AbaValidator.get_descriptive_record("1") == {:error, :incorrect_length}
    end

    test "returns an error if incorrect starting code" do
      entry =
        "1                 01CBA       test                      301500221212121227121222                                        "

      assert AbaValidator.get_descriptive_record(entry) ==
               {:error, :incorrect_starting_code}
    end

    test "returns an error if invalid string" do
      entry =
        "0                   CBA       test                      301500221212121227121222                                        "

      assert AbaValidator.get_descriptive_record(entry) ==
               {:error, :invalid_format, [:reel_sequence_number]}
    end

    test "returns an error if empty string" do
      entry =
        "0                                                                                                                       "

      assert AbaValidator.get_descriptive_record(entry) ==
               {:error, :invalid_format,
                [
                  :reel_sequence_number,
                  :bank_abbreviation,
                  :user_preferred_specification,
                  :user_id_number,
                  :description,
                  :date
                ]}
    end
  end

  describe "AbaValidator.get_file_total_record/2" do
    test "validates succesfully" do
      entry =
        "7999-999            000000000000000353890000035389                        000000                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:ok, {0, 35389, 35389, 0}}
    end

    test "returns an error if incorrect length with correct starting code" do
      assert AbaValidator.get_file_total_record("7") == {:error, :incorrect_length}
    end

    test "returns an error if incorrect length with incorrect starting code" do
      assert AbaValidator.get_file_total_record("1") == {:error, :incorrect_length}
    end

    test "returns an error if incorrect starting code" do
      entry =
        "1                 01CBA       test                      301500221212121227121222                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, :incorrect_starting_code}
    end

    test "returns an error if invalid string" do
      entry =
        "7999 999            000000000000000353890000035389                        000000                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, :invalid_format, [:bsb_filler]}
    end

    test "returns an error if empty string" do
      entry =
        "7                                                                                                                       "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, :invalid_format,
                [:bsb_filler, :net_total, :total_credit, :total_debit, :record_count]}
    end

    test "returns an error if balance don't match" do
      entry =
        "7999 999            000000000000000353890000035388                        000000                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, :invalid_format, [:bsb_filler, :net_total_mismatch]}
    end

    test "returns an error if records don't match" do
      entry =
        "7999 999            000000000000000353890000035389                        000002                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, :invalid_format, [:bsb_filler, :records_mismatch]}
    end
  end

  describe "AbaValidator.get_detail_record/1" do
    test "validates succesfully" do
      entry =
        "1032-898 12345678 130000035389 money                           Batch payment    040-404 12345678 test           00000000"

      assert AbaValidator.get_detail_record(entry) ==
               {:ok, {"032-898", "12345678", :blank, :externally_initiated_debit, 35389, " money",
                " Batch payment", "040-404", "12345678", " test", 0}}

      entry =
        "1032-8980-2345678N130000035389money                           Batch payment     040-404 12345678test            00000000"

      assert AbaValidator.get_detail_record(entry) ==
               {:ok, {"032-898", "0-2345678", :new_bank, :externally_initiated_debit, 35389,
                "money", "Batch payment", "040-404", "12345678", "test", 0}}
    end

    test "returns an error if incorrect length with correct starting code" do
      assert AbaValidator.get_detail_record("1") == {:error, :incorrect_length}
    end

    test "returns an error if incorrect length with incorrect starting code" do
      assert AbaValidator.get_detail_record("7") == {:error, :incorrect_length}
    end

    test "returns an error if incorrect starting code" do
      entry =
        "7032-898 12345678 130000035389money                           Batch payment     040-404 12345678test            00000000"

      assert AbaValidator.get_detail_record(entry) ==
               {:error, :incorrect_starting_code}
    end

    test "returns an error if invalid string" do
      entry =
        "1032 898 12345678 130000035389money                           Batch payment     040 404 12345678test            00000000"

      assert AbaValidator.get_detail_record(entry) ==
               {:error, :invalid_format, [:bsb, :trace_record]}
    end

    test "returns an error if empty string" do
      entry =
        "1                                                                                                                       "

      assert AbaValidator.get_detail_record(entry) ==
               {:error, :invalid_format,
                [
                  :bsb,
                  :account_number,
                  :transasction_code,
                  :amount,
                  :account_name,
                  :reference,
                  :trace_record,
                  :trace_account_number,
                  :remitter,
                  :withheld_tax
                ]}
    end
  end
end
