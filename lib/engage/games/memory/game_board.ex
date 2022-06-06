defmodule Engage.Games.Memory.GameBoard do
  alias Engage.Games.Memory.EmojiCard

  defstruct state: %{
              0 => %EmojiCard{symbol: "😂"},
              1 => %EmojiCard{symbol: "😂"},
              2 => %EmojiCard{symbol: "👻"},
              3 => %EmojiCard{symbol: "👻"},
              4 => %EmojiCard{symbol: "🐧"},
              5 => %EmojiCard{symbol: "🐧"},
              6 => %EmojiCard{symbol: "🧪"},
              7 => %EmojiCard{symbol: "🧪"},
              8 => %EmojiCard{symbol: "🚘"},
              9 => %EmojiCard{symbol: "🚘"},
              10 => %EmojiCard{symbol: "🧠"},
              11 => %EmojiCard{symbol: "🧠"},
              12 => %EmojiCard{symbol: "💜"},
              13 => %EmojiCard{symbol: "💜"},
              14 => %EmojiCard{symbol: "🤡"},
              15 => %EmojiCard{symbol: "🤡"},
              16 => %EmojiCard{symbol: "🤖"},
              17 => %EmojiCard{symbol: "🤖"},
              18 => %EmojiCard{symbol: "🎃"},
              19 => %EmojiCard{symbol: "🎃"},
              20 => %EmojiCard{symbol: "🔥"},
              21 => %EmojiCard{symbol: "🔥"},
              22 => %EmojiCard{symbol: "🌸"},
              23 => %EmojiCard{symbol: "🌸"},
              24 => %EmojiCard{symbol: "🍔"},
              25 => %EmojiCard{symbol: "🍔"},
              26 => %EmojiCard{symbol: "🥶"},
              27 => %EmojiCard{symbol: "🥶"},
              28 => %EmojiCard{symbol: "😡"},
              29 => %EmojiCard{symbol: "😡"}
            },
            current_player: :first,
            card_skin: nil
end
