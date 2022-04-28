defmodule Engage.Helpers.CodeGenerator do
  def generate(:four_alphanumeric_characters) do
    for _ <- 0..3, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyz')>>
  end
end
