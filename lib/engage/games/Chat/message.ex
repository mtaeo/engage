defmodule Engage.Games.Chat.Message do
  @enforce_keys [:sender, :text, :sent_at]
  defstruct [:sender, :text, :sent_at]
end
