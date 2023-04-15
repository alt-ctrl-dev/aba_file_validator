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
               {:ok,
                {"01", "CBA", "test                      ", "301500", "221212121227", "121222"}}
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
               {:error, {:invalid_format, [:reel_sequence_number]}}
    end

    test "returns an error if empty string" do
      entry =
        "0                                                                                                                       "

      assert AbaValidator.get_descriptive_record(entry) ==
               {:error,
                {:invalid_format,
                 [
                   :reel_sequence_number,
                   :bank_abbreviation,
                   :user_preferred_specification,
                   :user_id_number,
                   :description,
                   :date
                 ]}}
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
               {:error, {:invalid_format, [:bsb_filler]}}
    end

    test "returns an error if empty string" do
      entry =
        "7                                                                                                                       "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error,
                {:invalid_format,
                 [:bsb_filler, :net_total, :total_credit, :total_debit, :record_count]}}
    end

    test "returns an error if balance don't match" do
      entry =
        "7999 999            000000000000000353890000035388                        000000                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, {:invalid_format, [:bsb_filler, :net_total_mismatch]}}
    end

    test "returns an error if records don't match" do
      entry =
        "7999 999            000000000000000353890000035389                        000002                                        "

      assert AbaValidator.get_file_total_record(entry) ==
               {:error, {:invalid_format, [:bsb_filler, :records_mismatch]}}
    end
  end

  describe "AbaValidator.get_detail_record/1" do
    test "validates succesfully" do
      entry =
        "1032-898 12345678 130000035389 money                           Batch payment    040-404 12345678 test           00000000"

      assert AbaValidator.get_detail_record(entry) ==
               {:ok,
                {"032-898", "12345678", :blank, :externally_initiated_debit, 35389, " money",
                 " Batch payment", "040-404", "12345678", " test", 0}}

      entry =
        "1032-8980-2345678N130000035389money                           Batch payment     040-404 12345678test            00000000"

      assert AbaValidator.get_detail_record(entry) ==
               {:ok,
                {"032-898", "0-2345678", :new_bank, :externally_initiated_debit, 35389, "money",
                 "Batch payment", "040-404", "12345678", "test", 0}}
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
               {:error, {:invalid_format, [:bsb, :trace_record]}}
    end

    test "returns an error if empty string" do
      entry =
        "1                                                                                                                       "

      assert AbaValidator.get_detail_record(entry) ==
               {:error,
                {:invalid_format,
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
                 ]}}
    end
  end

  describe "AbaValidator.process_aba_file/1" do
    test "succesfully returns the correct content" do
      entry = "./test/helper/test.aba"

      assert AbaValidator.process_aba_file(entry) ==
               [
                 {:descriptive_record, :ok,
                  {"01", "CBA", "test                      ", "301500", "221212121227", "121222"}},
                 {:detail_record, :ok,
                  {"040-440", "123456", :blank, :externally_initiated_credit, 35389,
                   "4dd86..4936b", "Bank cashback", "040-404", "12345678", "test", 0}},
                 {:detail_record, :ok,
                  {"040-404", "12345678", :blank, :externally_initiated_debit, 35389, "Records",
                   "Fake payment", "040-404", "12345678", "test", 0}},
                 {:file_total_record, :output, {0, 35389, 35389, 2}}
               ]
    end

    test "succesfully gets errors" do
      entry = "./test/helper/test1.aba"

      assert AbaValidator.process_aba_file(entry) ==
               [
                 {:descriptive_record, :error, :incorrect_length},
                 {:detail_record, :error, {:invalid_format, [:bsb]}, 2},
                 {:detail_record, :error, :incorrect_length, 3},
                 {:file_total_record, :error, {:invalid_format, [:bsb_filler, :records_mismatch]}}
               ]
    end

    test "succesfully provides error if file doesn't exist" do
      assert AbaValidator.process_aba_file("1") == {:error, :file_doesnt_exists}
    end

    test "succesfully provides error if file is empty" do
      assert AbaValidator.process_aba_file("./test/helper/test.txt") ==
               {:error, :no_content}
    end

    test "succesfully provides error if the order is incorrect" do
      assert AbaValidator.process_aba_file("./test/helper/incorrect_order.aba") ==
               {:error, :incorrect_order_detected}
    end

    test "succesfully provides error if file has no read permission" do
      file_path = "./test/helper/permission.txt"
      File.touch!(file_path)
      File.chmod!(file_path, 0o020)

      assert AbaValidator.process_aba_file(file_path) ==
               {:error, :eacces}

      File.rm!(file_path)
    end

    test "succesfully provides error if multiple description records are present" do
      assert AbaValidator.process_aba_file("./test/helper/multiple_description_records.aba") ==
               {:error, :multiple_description_records, [line: 2]}
    end

    test "succesfully provides error if multiple file records are present" do
      assert AbaValidator.process_aba_file("./test/helper/multiple_file_records.aba") ==
               {:error, :multiple_file_total_records, [line: 2]}
    end
  end

  describe "AbaValidator.get_records/1" do
    test "succesfully returns the correct content when default type is used" do
      entry = "./test/helper/test.aba"

      assert AbaValidator.get_records(entry) ==
               {{:descriptive_record, :ok,
                 {"01", "CBA", "test                      ", "301500", "221212121227", "121222"}},
                [
                  {:detail_record, :ok,
                   {"040-440", "123456", :blank, :externally_initiated_credit, 35389,
                    "4dd86..4936b", "Bank cashback", "040-404", "12345678", "test", 0}},
                  {:detail_record, :ok,
                   {"040-404", "12345678", :blank, :externally_initiated_debit, 35389, "Records",
                    "Fake payment", "040-404", "12345678", "test", 0}}
                ], {:file_total_record, :output, {0, 35389, 35389, 2}}}
    end

    test "succesfully returns the correct content when type is :file_record" do
      entry = "./test/helper/test.aba"

      assert AbaValidator.get_records(entry, :file_record) ==
               {:file_total_record, :output, {0, 35389, 35389, 2}}
    end

    test "succesfully returns the correct content when type is :descriptive_record" do
      entry = "./test/helper/test.aba"

      assert AbaValidator.get_records(entry, :descriptive_record) ==
               {:descriptive_record, :ok,
                {"01", "CBA", "test                      ", "301500", "221212121227", "121222"}}
    end

    test "succesfully returns the correct content when type is :detail_record" do
      entry = "./test/helper/test.aba"

      assert AbaValidator.get_records(entry, :detail_record) ==
               [
                 {:detail_record, :ok,
                  {"040-440", "123456", :blank, :externally_initiated_credit, 35389,
                   "4dd86..4936b", "Bank cashback", "040-404", "12345678", "test", 0}},
                 {:detail_record, :ok,
                  {"040-404", "12345678", :blank, :externally_initiated_debit, 35389, "Records",
                   "Fake payment", "040-404", "12345678", "test", 0}}
               ]
    end

    test "succesfully gets errors" do
      entry = "./test/helper/test1.aba"

      assert AbaValidator.get_records(entry) ==
               {{:descriptive_record, :error, :incorrect_length},
                [
                  {:detail_record, :error, {:invalid_format, [:bsb]}, 2},
                  {:detail_record, :error, :incorrect_length, 3}
                ],
                {:file_total_record, :error, {:invalid_format, [:bsb_filler, :records_mismatch]}}}
    end

    test "succesfully provides error if file doesn't exist" do
      assert AbaValidator.get_records("1") == {:error, :file_doesnt_exists}
    end

    test "succesfully provides error if file is empty" do
      assert AbaValidator.get_records("./test/helper/test.txt") ==
               {:error, :no_content}
    end

    test "succesfully provides error if the order is incorrect" do
      assert AbaValidator.get_records("./test/helper/incorrect_order.aba") ==
               {:error, :incorrect_order_detected}
    end

    test "succesfully provides error if file has no read permission" do
      file_path = "./test/helper/permission.txt"
      File.touch!(file_path)
      File.chmod!(file_path, 0o020)

      assert AbaValidator.get_records(file_path) ==
               {:error, :eacces}

      File.rm!(file_path)
    end

    test "succesfully provides error if multiple description records are present" do
      assert AbaValidator.get_records("./test/helper/multiple_description_records.aba") ==
               {:error, :multiple_description_records, [line: 2]}
    end

    test "succesfully provides error if multiple file records are present" do
      assert AbaValidator.get_records("./test/helper/multiple_file_records.aba") ==
               {:error, :multiple_file_total_records, [line: 2]}
    end
  end
end
