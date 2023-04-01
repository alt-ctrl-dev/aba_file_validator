defmodule AbaFileValidatorTest do
  use ExUnit.Case
  doctest AbaFileValidator

  test "transaction code description" do
    assert AbaFileValidator.get_transaction_code_description(11) == :error
    assert AbaFileValidator.get_transaction_code_description(13) == "Externally initiated debit items"
    assert AbaFileValidator.get_transaction_code_description("13") == "Externally initiated debit items"
    assert AbaFileValidator.get_transaction_code_description(50) == "Externally initiated credit items with the exception of those bearing Transaction Codes"
    assert AbaFileValidator.get_transaction_code_description("50") == "Externally initiated credit items with the exception of those bearing Transaction Codes"
    assert AbaFileValidator.get_transaction_code_description(51) == "Australian Government Security Interest"
    assert AbaFileValidator.get_transaction_code_description("51") == "Australian Government Security Interest"
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
end
