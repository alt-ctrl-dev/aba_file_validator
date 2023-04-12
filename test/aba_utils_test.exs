defmodule AbaValidatorUtilsTest do
  use ExUnit.Case
  doctest AbaValidator.Utils
  import AbaValidator.Utils

  test "correct_length?/2" do
    assert correct_length?(11) == :error
    assert correct_length?("13") == false
    assert correct_length?("13", 2) == true
    assert correct_length?("  ", 2) == true
    assert correct_length?("", false) == :error
    assert correct_length?("") == true
  end

  test "string_empty?/1" do
    assert string_empty?(11) == :error
    assert string_empty?("13") == false
    assert string_empty?("  ") == true
  end

  test "valid_bsb?/1" do
    assert valid_bsb?(11) == false
    assert valid_bsb?("13") == false
    assert valid_bsb?("  ") == false
    assert valid_bsb?("123-231") == true
    assert valid_bsb?("123 231") == false
    assert valid_bsb?("1a3-231") == false
    assert valid_bsb?("123 231") == false
    assert valid_bsb?("123-1s1") == false
    assert valid_bsb?("a13-231") == false
  end

  test "valid_date?/2" do
    assert valid_date?(11) == :error
    assert valid_date?("13") == :error
    assert valid_date?("  ") == :error
    assert valid_date?("123231") == false
    assert valid_date?("120423") == true
  end
end
