defmodule AbaValidator.Guards do
  @moduledoc """
  Documentation for AbaValidator guards.
  """

  defguardp is_valid_record(record) when is_tuple(record) and tuple_size(record) == 3

  @doc """
  Returns true if term is a valid descriptive record; otherwise returns false.

  Allowed in guard tests.
  """
  defguard is_descriptive_record(descriptive_record)
           when is_valid_record(descriptive_record) and
                  elem(descriptive_record, 0) == :descriptive_record

  @doc """
  Returns true if term is a valid file record; otherwise returns false.

  Allowed in guard tests.
  """
  defguard is_file_record(descriptive_record)
           when is_valid_record(descriptive_record) and
                  elem(descriptive_record, 0) == :file_total_record

  @doc """
  Returns true if term is a valid detail record; otherwise returns false.

  Allowed in guard tests.
  """
  defguard is_detail_record(descriptive_record)
           when is_valid_record(descriptive_record) and
                  elem(descriptive_record, 0) == :detail_record
end
