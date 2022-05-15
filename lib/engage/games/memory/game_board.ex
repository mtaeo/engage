defmodule Engage.Games.Memory.GameBoard do
  alias Engage.Games.Generic.Coordinate
  alias Engage.Games.Memory.EmojiCard

  defstruct state: %{
    %Coordinate{x: 0, y: 0} => %EmojiCard{symbol: "😂"},
    %Coordinate{x: 0, y: 1} => %EmojiCard{symbol: "😂"},
    %Coordinate{x: 0, y: 2} => %EmojiCard{symbol: "👻"},
    %Coordinate{x: 0, y: 3} => %EmojiCard{symbol: "👻"},
    %Coordinate{x: 1, y: 0} => %EmojiCard{symbol: "🕷"},
    %Coordinate{x: 1, y: 1} => %EmojiCard{symbol: "🕷"},
    %Coordinate{x: 1, y: 2} => %EmojiCard{symbol: "🧪"},
    %Coordinate{x: 1, y: 3} => %EmojiCard{symbol: "🧪"},
    %Coordinate{x: 2, y: 0} => %EmojiCard{symbol: "🚘"},
    %Coordinate{x: 2, y: 1} => %EmojiCard{symbol: "🚘"},
    %Coordinate{x: 2, y: 2} => %EmojiCard{symbol: "🧠"},
    %Coordinate{x: 2, y: 3} => %EmojiCard{symbol: "🧠"},
  }
end
