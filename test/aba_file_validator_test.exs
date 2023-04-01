defmodule AbaFileValidatorTest do
  use ExUnit.Case
  doctest AbaFileValidator

  test "AbaFileValidator.get_transaction_code_description/1" do
    assert AbaFileValidator.get_transaction_code_description(11) == :error

    assert AbaFileValidator.get_transaction_code_description(13) ==
             "Externally initiated debit items"

    assert AbaFileValidator.get_transaction_code_description("13") ==
             "Externally initiated debit items"

    assert AbaFileValidator.get_transaction_code_description(50) ==
             "Externally initiated credit items with the exception of those bearing Transaction Codes"

    assert AbaFileValidator.get_transaction_code_description("50") ==
             "Externally initiated credit items with the exception of those bearing Transaction Codes"

    assert AbaFileValidator.get_transaction_code_description(51) ==
             "Australian Government Security Interest"

    assert AbaFileValidator.get_transaction_code_description("51") ==
             "Australian Government Security Interest"

    assert AbaFileValidator.get_transaction_code_description(52) == "Family Allowance"
    assert AbaFileValidator.get_transaction_code_description("52") == "Family Allowance"
    assert AbaFileValidator.get_transaction_code_description(53) == "Pay"
    assert AbaFileValidator.get_transaction_code_description("53") == "Pay"
    assert AbaFileValidator.get_transaction_code_description(54) == "Pension"
    assert AbaFileValidator.get_transaction_code_description("54") == "Pension"
    assert AbaFileValidator.get_transaction_code_description(55) == "Allotment"
    assert AbaFileValidator.get_transaction_code_description("55") == "Allotment"
    assert AbaFileValidator.get_transaction_code_description(56) == "Dividend"
    assert AbaFileValidator.get_transaction_code_description("56") == "Dividend"
    assert AbaFileValidator.get_transaction_code_description(57) == "Debenture/Note Interest"
    assert AbaFileValidator.get_transaction_code_description("57") == "Debenture/Note Interest"
  end

  describe "AbaFileValidator.validate_descriptive_record/1" do
    test "validates succesfully" do
      entry =
        "0                 01CBA       test                      301500221212121227121222                                        "

      assert AbaFileValidator.validate_descriptive_record(entry) == :ok
    end

    test "returns an error if first character is not zero" do
      assert AbaFileValidator.validate_descriptive_record("1") == {:error, :incorrect_length}
    end

    test "if first character is not zero" do
      entry =
        "1                 01CBA       test                      301500221212121227121222                                        "

      assert AbaFileValidator.validate_descriptive_record(entry) ==
               {:error, :incorrect_starting_code}
    end
  end
end
