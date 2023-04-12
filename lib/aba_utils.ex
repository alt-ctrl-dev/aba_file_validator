defmodule AbaValidator.Utils do
  @moduledoc false

  @spec correct_length?(String.t(), integer()) :: :error | boolean()
  @doc """
  Checks if the length of the string matches to the defined 'n' value

  ## Examples

      iex> AbaValidator.Utils.correct_length?(1)
      :error

      iex> AbaValidator.Utils.correct_length?("", false)
      :error

      iex> AbaValidator.Utils.correct_length?("11")
      false

      iex> AbaValidator.Utils.correct_length?("01",2)
      true

      iex> AbaValidator.Utils.correct_length?(" " ,1 )
      true

  """
  def correct_length?(entry, n \\ 0)
  def correct_length?(entry, n) when not is_binary(entry) or not is_integer(n), do: :error
  def correct_length?(entry, n) when is_binary(entry), do: String.length(entry) == n

  @spec string_empty?(String.t()) :: :error | boolean()
  @doc """
  Checks if the string is empty

  ## Examples

      iex> AbaValidator.Utils.string_empty?(1)
      :error

      iex> AbaValidator.Utils.string_empty?("11")
      false

      iex> AbaValidator.Utils.string_empty?(" " )
      true

  """
  def string_empty?(entry) when not is_binary(entry), do: :error
  def string_empty?(entry) when is_binary(entry), do: String.trim(entry) |> String.length() == 0

  @spec valid_date?(String.t(), String.t()) :: :error | boolean()
  @doc """
  Checks if the date string is valid. If a year prefix is not provided then it will consider it as first two digits of the current year

  ## Examples

      iex> AbaValidator.Utils.valid_date?(1)
      :error

      iex> AbaValidator.Utils.valid_date?("11")
      :error

      iex> AbaValidator.Utils.valid_date?(" ")
      :error

      iex> AbaValidator.Utils.valid_date?("")
      :error

      iex> AbaValidator.Utils.valid_date?("123231")
      false

      iex> AbaValidator.Utils.valid_date?("120423")
      true
  """
  def valid_date?(date, year_prefix \\ "")

  def valid_date?(<<dd::binary-2, mm::binary-2, yy::binary-2>> = date, year_prefix)
      when is_binary(date) and is_binary(year_prefix) do
    if string_empty?(dd) or
         string_empty?(mm) or
         string_empty?(yy) do
      false
    else
      year_prefix =
        if String.trim(year_prefix) |> String.length() === 0 do
          <<prefix::binary-2, _::binary-2>> = Integer.to_string(NaiveDateTime.utc_now().year)
          prefix
        else
          year_prefix
        end

      [yy, mm, dd] = for i <- [year_prefix <> yy, mm, dd], do: String.to_integer(i)

      NaiveDateTime.new(2000 + yy, mm, dd, 0, 0, 0)
      |> case do
        {:ok, _} -> true
        {:error, _} -> false
      end
    end
  end

  def valid_date?(_, _), do: :error

  @spec valid_bsb?(String.t()) :: boolean()
  @doc """
  Checks if the string is a valid bsb format

  ## Examples

      iex> AbaValidator.Utils.valid_bsb?(1)
      false

      iex> AbaValidator.Utils.valid_bsb?("123 231")
      false

      iex> AbaValidator.Utils.valid_bsb?("123-2a1")
      false

      iex> AbaValidator.Utils.valid_bsb?("11")
      false

      iex> AbaValidator.Utils.valid_bsb?("123-312" )
      true

  """
  def valid_bsb?(<<first::binary-3, <<45>>, last::binary-3>>) do
    cond do
      string_empty?(first) or
          string_empty?(last) ->
        false

      Integer.parse(first) === :error ->
        false

      String.match?(first, ~r/\d{3}/) === false ->
        false

      Integer.parse(last) === :error ->
        false

      String.match?(last, ~r/\d{3}/) === false ->
        false

      true ->
        true
    end
  end

  def valid_bsb?(_bsb), do: false
end
