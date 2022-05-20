defmodule Engage.Helpers.CodeGenerator do
  def generate(:four_alphanumeric_characters) do
    for _ <- 0..3, into: "", do: <<Enum.random('0123456789abcdefghijklmnopqrstuvwxyz')>>
  end

  # TODO: Refactor into more advanced username generation based on users nickname or first name
  def generate(:username) do
    for _ <- 0..5, into: "", do: <<Enum.random(?a..?z)>>
  end
end
