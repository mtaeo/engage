defmodule Engage.Games.Memory.GameBoard do
  alias Engage.Games.Memory.EmojiCard

  defstruct state: %{
              0 => %EmojiCard{symbol: "๐"},
              1 => %EmojiCard{symbol: "๐"},
              2 => %EmojiCard{symbol: "๐ป"},
              3 => %EmojiCard{symbol: "๐ป"},
              4 => %EmojiCard{symbol: "๐ง"},
              5 => %EmojiCard{symbol: "๐ง"},
              6 => %EmojiCard{symbol: "๐งช"},
              7 => %EmojiCard{symbol: "๐งช"},
              8 => %EmojiCard{symbol: "๐"},
              9 => %EmojiCard{symbol: "๐"},
              10 => %EmojiCard{symbol: "๐ง "},
              11 => %EmojiCard{symbol: "๐ง "},
              12 => %EmojiCard{symbol: "๐"},
              13 => %EmojiCard{symbol: "๐"},
              14 => %EmojiCard{symbol: "๐คก"},
              15 => %EmojiCard{symbol: "๐คก"},
              16 => %EmojiCard{symbol: "๐ค"},
              17 => %EmojiCard{symbol: "๐ค"},
              18 => %EmojiCard{symbol: "๐"},
              19 => %EmojiCard{symbol: "๐"},
              20 => %EmojiCard{symbol: "๐ฅ"},
              21 => %EmojiCard{symbol: "๐ฅ"},
              22 => %EmojiCard{symbol: "๐ธ"},
              23 => %EmojiCard{symbol: "๐ธ"},
              24 => %EmojiCard{symbol: "๐"},
              25 => %EmojiCard{symbol: "๐"},
              26 => %EmojiCard{symbol: "๐ฅถ"},
              27 => %EmojiCard{symbol: "๐ฅถ"},
              28 => %EmojiCard{symbol: "๐ก"},
              29 => %EmojiCard{symbol: "๐ก"}
            },
            current_player: :first,
            card_skin: nil
end
