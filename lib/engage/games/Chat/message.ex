defmodule Engage.Games.Chat.Message do
  @enforce_keys [:sender, :text, :avatar_src]
  defstruct [:sender, :text, :avatar_src]
end
