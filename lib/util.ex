defmodule AbaFileValidator.Utils do
  def correct_length?(entry) when is_binary(entry), do: String.length(entry) == 120
end
