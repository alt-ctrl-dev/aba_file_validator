defmodule AbaValidator.MultipleDescriptionRecordsError do
  @moduledoc """
  Documentation for MultipleDescriptionRecordsError.

  Usage

  ```raise MultipleDescriptionRecordsError, line_number```

  ```raise MultipleDescriptionRecordsError, [line: line_number]```
  """
  defexception [:message, :line]

  @impl true
  def exception([line: line] = args) when is_list(args) do
    %AbaValidator.MultipleDescriptionRecordsError{
      message: "Multiple description records in file",
      line: line
    }
  end

  def exception(line) when is_integer(line) do
    %AbaValidator.MultipleDescriptionRecordsError{
      message: "Multiple description records in file",
      line: line
    }
  end
end

defmodule AbaValidator.MultipleFileRecordsError do
  @moduledoc """
  Documentation for MultipleFileRecordsError.

  Usage

  ```raise MultipleFileRecordsError, line_number```

  ```raise MultipleFileRecordsError, [line: line_number]```
  """
  defexception [:message, :line]
  @impl true
  def exception([line: line] = args) when is_list(args) do
    %AbaValidator.MultipleFileRecordsError{message: "Multiple file total records in file", line: line}
  end

  def exception(line) when is_integer(line) do
    %AbaValidator.MultipleFileRecordsError{message: "Multiple file total records in file", line: line}
  end
end
