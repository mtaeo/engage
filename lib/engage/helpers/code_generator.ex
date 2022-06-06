defmodule Engage.Helpers.CodeGenerator do
  def generate_game_code() do
    for _ <- 0..3, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyz')>>
  end

  def generate_username(name) when is_binary(name) do
    code = for _ <- 0..3, into: "", do: <<Enum.random(?0..?9)>>
    String.trim(name) <> "-" <> code
  end
end
