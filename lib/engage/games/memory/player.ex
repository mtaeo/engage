defmodule Engage.Games.Memory.Player do
  defstruct [:id, :name, matched_pairs_current_game: 0, score: 0]
end
