defmodule AbaValidator.Utils do
  def correct_length?(entry, n) when is_binary(entry), do: String.length(entry) == n

  def string_empty?(entry) when is_binary(entry), do: String.trim(entry) |> String.length() == 0

  @spec valid_date?(String.t()) :: boolean
  def valid_date?(<<dd::binary-2, mm::binary-2, yy::binary-2>>) do
    if string_empty?(dd) or
         string_empty?(mm) or
         string_empty?(yy) do
      false
    else
      [yy, mm, dd] = for i <- [yy, mm, dd], do: String.to_integer(i)

      NaiveDateTime.new(2000 + yy, mm, dd, 0, 0, 0)
      |> case do
        {:ok, _} -> true
        {:error, _} -> false
      end
    end
  end

  @spec valid_bsb?(String.t()) :: boolean
  def valid_bsb?(<<first::binary-3, <<45>>, last::binary-3>>) do
    cond do
      string_empty?(first) or
          string_empty?(last) ->
        false

      Integer.parse(first) === :error ->
        false

      Integer.parse(last) === :error ->
        false

      true ->
        true
    end
  end

  def valid_bsb?(_bsb), do: false
end
