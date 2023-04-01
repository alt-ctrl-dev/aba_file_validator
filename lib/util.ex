defmodule AbaFileValidator.Utils do
  def correct_length?(entry,n) when is_binary(entry), do: String.length(entry) == n
  def string_empty?(entry) when is_binary(entry), do: String.trim(entry) |> String.length() == 0

  def valid_date?(<<dd::binary-2, mm::binary-2, yy::binary-2>>) do
    [yy, mm, dd] = for i <- [yy, mm, dd], do: String.to_integer(i)
    NaiveDateTime.new(2000+yy, mm, dd, 0, 0, 0)
    |> case do
      {:ok, _} -> true
      {:error, _} -> false
    end
  end
end
